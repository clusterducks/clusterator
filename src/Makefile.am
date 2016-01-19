dist_bin_SCRIPTS = cluster-start cluster-stop create-machines

systemddir = @sysconfdir@/systemd/system
systemd_DATA = cluster-start.service cluster-stop.service

create-machines: create-machines.sh
	echo "$<" "$@"
	sed -e 's,@BASHLIBS@,@libexecdir@,g' < "$<" > "$@"

mostlyclean-local:
	-rm -f create-machines
