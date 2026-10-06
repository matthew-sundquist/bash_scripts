
awk 'BEGIN { n=0 } /^top -/ { n++ } n >= 2' top.txt > filtered_output.txt

awk '
/^[[:space:]]*[0-9]+[[:space:]]/ {
    tid=$1
    cmd="cat /proc/" tid "/comm 2>/dev/null"
    if ((cmd | getline name) > 0) {
        sub(/[[:space:]]+[^[:space:]]+$/, "")
        $0 = $0 " " name
    }
    close(cmd)
}
{ print }
' filtered_output.txt > full_names.txt

awk '
/^[[:space:]]*[0-9]+[[:space:]]/ {
    tid = $1

    # Get owning PID (TGID)
    cmd = "ps -eL -o pid=,tid= | awk '\''$2 == " tid " {print $1}'\''"
    cmd | getline pid
    close(cmd)

    # Get process name
    cmd = "ps -p " pid " -o comm="
    cmd | getline process
    close(cmd)

    print $0, process
    next
}
{ print }
' full_names.txt > all_done.txt
