#!/usr/bin/awk -f

function spaces(n,   s){ s=""; while (length(s)<n) s=s " "; return s }
function center(txt, w,   pad,left,right){
    if (w <= 0) return ""
    pad = w - length(txt); if (pad < 0) pad = 0
    left = int(pad/2); right = pad - left
    return sprintf("%*s%s%*s", left, "", txt, right, "")
}
function pad_left(s,w, k){ k=w-length(s); return (k>0?sprintf("%"k"s",""):"") s }
function pad_right(s,w,k){ k=w-length(s); return s (k>0?sprintf("%"k"s",""):"") }
function rule_spaces(w){ return spaces(w) }

# Abbrev SLURM state
function abbrev_state(s, u){
    u=toupper(s)
    if(u=="PENDING")return"PD"; if(u=="RUNNING")return"R";  if(u=="COMPLETED")return"CD"
    if(u=="CANCELLED")return"CA";if(u=="FAILED")return"F";  if(u=="SUSPENDED")return"S"
    if(u=="CONFIGURING")return"CF"; if(u=="COMPLETING")return"CG"; if(u=="TIMEOUT")return"TO"
    if(u=="PREEMPTED")return"PR"; if(u=="NODE_FAIL")return"NF"; if(u=="OUT_OF_MEMORY")return"OOM"
    return substr(u,1,(length(u)>=2?2:1))
}

# Parse "DD-HH:MM:SS" | "HH:MM:SS" | "MM:SS" | "UNLIMITED"
function parse_seconds(t, d,h,m,s,a,n){
    t=ttrim(t)
    if(t ~ /UNLIMITED|Infinite|Not Set/i) return -1
    d=h=m=s=0
    if(t ~ /-/){ split(t,a,"-"); d=a[1]+0; t=a[2] }
    n=split(t,a,":")
    if(n==3){ h=a[1]+0; m=a[2]+0; s=a[3]+0 }
    else if(n==2){ m=a[1]+0; s=a[2]+0 }
    else if(n==1){ s=a[1]+0 }
    return d*86400+h*3600+m*60+s
}

function ttrim(s){ sub(/^[[:space:]]+/,"",s); sub(/[[:space:]]+$/,"",s); return s }

# TIME: <1h -> MM.t (tenths rounded); >=1h -> H:MM (days folded into H)
function fmt_time(t, sec,mm,ss,dec,H,mins){
    sec=parse_seconds(t); if(sec<0) return "--"
    if(sec<3600){
        mm=int(sec/60); ss=sec-mm*60
        dec=int(ss/6 + 0.5); if(dec==10){ mm+=1; dec=0 }
        return mm "." dec
    }else{
        H=int(sec/3600)
        mins=int(((sec-H*3600)/60)+0.5); if(mins==60){ H+=1; mins=0 }
        return H ":" (mins<10?"0" mins:mins)
    }
}

# TL: show REQUESTED limit (%l) as hours; UNLIMITED -> "--"
function fmt_tl_hours(tl,sec,h){
    sec=parse_seconds(tl)
    if(sec<0) return "--"
    h=int(sec/3600+0.5); return h ""
}

# Name: strip trailing _[A-Z0-9]{10}$ then mid-ellipsis (⋯) to width 22 with left bias
function tidy_name(n, keep,lft,rgt){
    n=ttrim(n)
    if(n ~ /_[A-Z0-9]{10}$/) sub(/_[A-Z0-9]{10}$/,"",n)
    if(length(n)<=22) return n
    keep=21
    lft=int(0.6*keep + 0.9999); if(lft<1) lft=1
    rgt=keep-lft; if(rgt<1){ rgt=1; lft=keep-rgt }
    return substr(n,1,lft) "⋯" substr(n,length(n)-rgt+1)
}

BEGIN{
    FS="|"; OFS="|"

    # Portrait: 5 columns
    cols=5
    hdr[1]="JOBID"
    hdr[2]="ST"
    hdr[3]="JOB NAME"
    hdr[4]="TIME"
    hdr[5]="TL"

    name_col=3

    # Gutters & padding
    left_gutter=1; lg=spaces(left_gutter)
    for(i=1;i<=cols;i++){ pad[i]=1; padL[i]=1; padR[i]=1 }

    # Content widths start from headers
    for(i=1;i<=cols;i++){ content[i]=length(hdr[i]); from_header[i]=1 }

    # ANSI underline controls
    UL_SINGLE = "\033[4m"    # single underline on
    UL_DOUBLE = "\033[4:2m"  # double underline on
    UL_OFF    = "\033[24m"   # underline off

    n=0
    # Terminal width (for full-width divider)
    termw = (termw+0 ? termw+0 : 120)
}

# Ingest rows from 8-field squeue; remap into 5 display columns w/ transforms
{
    n++
    raw_jobid = ttrim($1)
    raw_state = ttrim($2)
    raw_name  = ttrim($3)
    raw_time  = ttrim($6)   # %M
    raw_tl    = ttrim($7)   # %l

    cell[n,1]=raw_jobid
    cell[n,2]=abbrev_state(raw_state)
    cell[n,3]=tidy_name(raw_name)
    cell[n,4]=fmt_time(raw_time)
    cell[n,5]=fmt_tl_hours(raw_tl)

    for(i=1;i<=cols;i++){
        L = length(cell[n,i])
        if(L > content[i]){ content[i]=L; from_header[i]=0 }
    }
}

function recompute_total( i){
    total = left_gutter + (cols-1)   # pipes
    for(i=1;i<=cols;i++){
        padL[i]=pad[i]; padR[i]=pad[i]
        colw[i]=padL[i] + content[i] + padR[i]
        total += colw[i]
    }
}

END{
    # 1) Base widths
    recompute_total()

    # 2) If too wide, reduce padding down to 1 per side symmetrically (no content shrink)
    if(total > termw){
        overflow = total - termw
        # First take from left gutter, then symmetric per-column pads
        if(left_gutter > 1){
            take = (left_gutter-1 < overflow ? left_gutter-1 : overflow)
            left_gutter -= take; lg=spaces(left_gutter); overflow -= take
            recompute_total()
        }
        while(overflow>0){
            changed=0
            for(i=1;i<=cols;i++){
                if(padL[i]>1){ padL[i]--; changed=1; overflow--; if(overflow==0)break }
                if(padR[i]>1){ padR[i]--; changed=1; overflow--; if(overflow==0)break }
            }
            if(!changed) break
            # remeasure widths
            total = left_gutter + (cols-1)
            for(i=1;i<=cols;i++){ colw[i]=padL[i]+content[i]+padR[i]; total += colw[i] }
        }
    }

    # 3) HEADER (boxed): top spacer, labels, bottom spacer (double underline)

    # 3a) Top spacer row (with pipes, no underline)
    line = lg
    for (i=1;i<=cols;i++) {
        cellh = spaces(padL[i]) spaces(content[i]) spaces(padR[i])
        line  = (i==1 ? line cellh : line "|" cellh)
    }
    print line

    # 3b) Header labels row (single-underlined header text only)
    line = lg
    for (i=1;i<=cols;i++) {
        inner = content[i]
        lpad = int((inner - length(hdr[i]))/2); if (lpad < 0) lpad = 0
        rpad = inner - length(hdr[i]) - lpad;   if (rpad < 0) rpad = 0
        cellh = spaces(padL[i]) spaces(lpad) UL_SINGLE hdr[i] UL_OFF spaces(rpad) spaces(padR[i])
        line  = (i==1 ? line cellh : line "|" cellh)
    }
    print line

    # 3c) Bottom spacer row (double underline across the entire row incl. pipes)
    line = lg
    for (i=1;i<=cols;i++) {
        cellh = spaces(padL[i]) spaces(content[i]) spaces(padR[i])
        line  = (i==1 ? line cellh : line "|" cellh)
    }
    printf("%s%s%s\n", UL_DOUBLE, line, UL_OFF) 

    # 4) Data rows (ST/TIME/TL right-aligned; exactly one trailing space)
    for(r=1;r<=n;r++){
        line = lg
        for(i=1;i<=cols;i++){
            inner = content[i]
            txt = cell[r,i]
            if(length(txt) > inner) txt = substr(txt,1,inner)
            if(i==2 || i==4 || i==5){ # right-align numeric-ish
                cellb = spaces(padL[i]) pad_left(txt, inner) spaces(padR[i])
            } else if(i==3){
                cellb = spaces(padL[i]) pad_right(txt, inner) spaces(padR[i])
            } else {
                cellb = spaces(padL[i]) pad_right(txt, inner) spaces(padR[i])
            }
            line = (i==1 ? line cellb : line "|" cellb)
        }
        print line
    }
}

