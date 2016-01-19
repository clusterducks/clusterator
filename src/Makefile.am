dist_bin_SCRIPTS = cluster-start cluster-stop create-machines start-consul docker-machines

systemddir = @sysconfdir@/systemd/system
systemd_DATA = cluster-start.service cluster-stop.service

start-consul: start-consul.sh
	sed -e 's,@BARNEYDIR@,@bindir@,g' < "$<" > "$@"

create-machines: create-machines.sh
	sed -e 's,@BASHLIBS@,@libexecdir@,g' < "$<" > "$@"

mostlyclean-local:
	-rm -f create-machines start-consul
