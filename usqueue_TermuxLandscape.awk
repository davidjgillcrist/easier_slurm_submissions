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
function ttrim(s){ sub(/^[[:space:]]+/,"",s); sub(/[[:space:]]+$/,"",s); return s }

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

# Ellipsis for NAME like portrait (⋯) to fit 'target' width, w/ slight left bias
function ellipsize_name(n, target,   keep,lft,rgt){
    if (length(n) <= target) return n
    keep = target - 1; if (keep < 1) keep = 1
    lft = int(0.6*keep + 0.9999); if (lft < 1) lft = 1
    rgt = keep - lft; if (rgt < 1) { rgt = 1; lft = keep - rgt }
    return substr(n,1,lft) "⋯" substr(n, length(n)-rgt+1)
}

# Strip trailing _[A-Z0-9]{10}$
function strip_job_suffix(n){ n=ttrim(n); if(n ~ /_[A-Z0-9]{10}$/) sub(/_[A-Z0-9]{10}$/,"",n); return n }

BEGIN{
    FS="|"; OFS="|"; cols=8

    # Headers / labels (NODELIST only)
    hdr[1]="JOBID"
    hdr[2]="ST"
    hdr[3]="JOB NAME"
    hdr[4]="CPUS"
    hdr[5]="MEM"
    hdr[6]="TIME"
    hdr[7]="TL"
    hdr[8]="NODELIST"

    name_col=3

    # Single-padding baseline like portrait
    left_gutter = 1
    right_gutter = 1                # keep one trailing space on each row
    lg = spaces(left_gutter)

    for (i=1;i<=cols;i++) { pad[i]=1; padL[i]=1; padR[i]=1 }
    for (i=1;i<=cols;i++) { content[i]=length(hdr[i]); from_header[i]=1 }

    # ANSI underline controls
    UL_SINGLE = "\033[4m"    # single underline on
    UL_DOUBLE = "\033[4:2m"  # double underline on
    UL_OFF    = "\033[24m"   # underline off

    n=0
    termw = (termw+0 ? termw+0 : 120)

    # Padding growth priority (when we have extra width): NAME -> NODE -> TIME -> TL -> MEM -> CPUS -> JOBID -> ST
    inc_pr[1]=3; inc_pr[2]=8; inc_pr[3]=6; inc_pr[4]=7; inc_pr[5]=5; inc_pr[6]=4; inc_pr[7]=1; inc_pr[8]=2; inc_count=8
}

# Ingest rows from 8-field squeue; transform
{
    n++
    raw1=$1; raw2=$2; raw3=$3; raw4=$4; raw5=$5; raw6=$6; raw7=$7; raw8=$8

    cell[n,1]=ttrim(raw1)
    cell[n,2]=abbrev_state(raw2)
    cell[n,3]=strip_job_suffix(raw3)
    cell[n,4]=ttrim(raw4)
    cell[n,5]=ttrim(raw5)
    cell[n,6]=fmt_time(raw6)
    cell[n,7]=fmt_tl_hours(raw7)
    cell[n,8]=ttrim(raw8)

    for (i=1;i<=cols;i++) {
        L=length(cell[n,i])
        if (L > content[i]) { content[i]=L; from_header[i]=0 }
    }
}

function recompute_total(   i){
    total = left_gutter + right_gutter + (cols-1)   # pipes count only the '|' char; pads are in colw
    for (i=1;i<=cols;i++) {
        padL[i] = pad[i]; padR[i] = pad[i]
        colw[i] = padL[i] + content[i] + padR[i]
        total += colw[i]
    }
}

END{
    # 1) Base widths
    recompute_total()

    # 2) Ensure narrow visual floors for numeric-ish cols (so rules don't look broken)
    if (content[2] < 2) content[2]=2    # ST
    if (content[6] < 4) content[6]=4    # TIME
    if (content[7] < 2) content[7]=2    # TL
    recompute_total()

    # 3) If total exceeds termw, shrink JOB NAME content width just enough to fit (like portrait)
    if (total > termw) {
        overflow = total - termw
        min_name = length(hdr[name_col]) + 2     # header + punctuation room
        target = content[name_col] - overflow
        if (target < min_name) target = min_name
        if (target < 1) target = 1
        content[name_col] = target
        recompute_total()
    }

    # 4) If still exceeds (extreme case), keep shrinking NAME down to header width
    if (total > termw) {
        content[name_col] = length(hdr[name_col])
        recompute_total()
    }

    # 5) If narrower than termw, grow symmetric padding by priority (like original)
    if (total < termw) {
        extra = termw - total
        while (extra >= 2) {
            progressed=0
            for (k=1; k<=inc_count && extra>=2; k++) {
                i = inc_pr[k]
                pad[i]++
                padL[i]=pad[i]; padR[i]=pad[i]
                extra -= 2
                progressed=1
            }
            if (!progressed) break
        }
        # If 1 leftover, bias to LEFT of JOBID (keeps right edge clean)
        if (extra == 1) {
            i = 1
            padL[i] = pad[i] + 1
            extra--
        }
        recompute_total()
    }

    # ----------------- HEADER (boxed) -----------------
    # 1) Top spacer row (no underline), includes pipes
    line = lg
    for (i=1;i<=cols;i++) {
        cellh = spaces(padL[i]) spaces(content[i]) spaces(padR[i])
        line  = (i==1 ? line cellh : line "|" cellh)
    }
    print line

    # 2) Header labels row (single-underlined text only), includes pipes
    line = lg
    for (i=1;i<=cols;i++) {
        inner = content[i]
        lpad = int((inner - length(hdr[i]))/2); if (lpad < 0) lpad = 0
        rpad = inner - length(hdr[i]) - lpad;   if (rpad < 0) rpad = 0
        cellh = spaces(padL[i]) spaces(lpad) UL_SINGLE hdr[i] UL_OFF spaces(rpad) spaces(padR[i])
        line  = (i==1 ? line cellh : line "|" cellh)
    }
    print line

    # 3) Bottom spacer row (double underline across entire row incl. pipes)
    line = lg
    for (i=1;i<=cols;i++) {
        cellh = spaces(padL[i]) spaces(content[i]) spaces(padR[i])
        line  = (i==1 ? line cellh : line "|" cellh)
    }
    printf("%s%s%s\n", UL_DOUBLE, line, UL_OFF)

    # ----------------- Rows -----------------
    for (r=1;r<=n;r++) {
        # Main line
        line = lg
        for (i=1;i<=cols;i++) {
            inner = content[i]
            txt = cell[r,i]

            # Apply NAME mid-ellipsis at print to fit 'inner'
            if (i==name_col && length(txt) > inner) {
                txt = ellipsize_name(txt, inner)
            } else if (length(txt) > inner) {
                # For non-NAME, hard trim to inner
                txt = substr(txt, 1, inner)
            }

            # Alignment per column
            if (i==2 || i==4 || i==5 || i==6 || i==7) {    # ST, CPUS, MEM, TIME, TL
                body = pad_left(txt, inner)
            } else {                                        # JOBID, NAME, NODE
                body = pad_right(txt, inner)
            }

            cellb = spaces(padL[i]) body spaces(padR[i])
            line  = (i==1 ? line cellb : line "|" cellb)
        }
        # add right gutter
        line = line spaces(right_gutter)
        print line
    }
}
