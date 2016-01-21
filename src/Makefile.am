dist_bin_SCRIPTS = create-machines destroy-machines start-consul docker-machines
data_DATA = docker-compose.yml

systemddir = @sysconfdir@/systemd/system
systemd_DATA = cluster-start.service cluster-stop.service

start-consul: start-consul.sh
	sed -e 's,@BARNEYDIR@,@bindir@,g;s,@ADATADIR@,@datadir@,g' < "$<" > "$@"

*-machines: *-machines.sh
	sed -e 's,@BASHLIBS@,@libexecdir@,g' < "$<" > "$@"

mostlyclean-local:
	-rm -f create-machines destroy-machines start-consul
