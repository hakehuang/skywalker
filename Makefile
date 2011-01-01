SUBDIR=uboot-env udp_sync

all:
	for i in $(SUBDIR); do make -C $$i; done

install:
	@echo "please cp vte_script/gen_html.sh to shlx12 /rootfs/wb/"   
	@echo "please cp vte_script/gen_report.php to shlx12 /var/www/test_reports/"
	@echo "please vte_script/vte to rootfs sever /rootfs/"

clean:
	for i in $(SUBDIR); do make  -C $$i clean; done
