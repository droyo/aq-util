#!/bin/sh
# readopt - Portable command-line options parser
# Usage: eval `readopt 'a,b,c desc' -abc arg`
# See readopt(1)

if [ $# -gt 0 -a "$1" = -s ] ; then
	shift=1; shift;
fi

if [ $# -lt 1 ] ; then
	echo "Usage: readopt [ -s ] opt-spec [ args ... ]" >/dev/stderr
	exit 1
fi

fmt="$1" ; shift
for i do printf "%s\n" "$i"
done | awk -v fmt="$fmt" -v shift=$shift '
BEGIN { 
	gsub(/[ \t\n\r]/,"",fmt)
	split(fmt,opts,",")
	for(i in opts) {
		o=substr(opts[i],1,1)
		nargs[o]=length(opts[i])
	}
}
want { s++; flags[want]=$0; want=""; next }
/^-[a-zA-Z]+/ {
	s++
	sub(/^-/,"")
	for(i=1;i<=length($0);i++) {
		c = substr($0,i,1)
		if (!nargs[c]||(nargs[c]>=2 && want)) {
			error=1
			exit
		} 
		else if (nargs[c]>=2) want=c
		else if (nargs[c]==1) flags[c]=1
	}
	next
}
{ exit }
END { 
	printf("status='\''%s'\''\n",error?"usage":"")
	if (error) exit 
	for (f in nargs) 
		printf("flag%s='\''%s'\''\n",f,flags[f])
	if (s && shift) print "shift "s
	exit 0
}'
