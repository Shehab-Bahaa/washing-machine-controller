################################ Makefile for washing machine controller Project
# =============================================================================
# Project Paths
rtl_path  = "F:/MixelTask/washing_machine/rtl"
tb_path   = "F:/MixelTask/washing_machine/tb"
work_path = "../questa_directory"
# =============================================================================
# FLAGS
SHOW_WAVEFORM_FLAG =0
# =============================================================================
########################## pass test_name from the command line. Ex. make test_name=test1 compile_all
compile_all: 
	@vlog +cover+bcs -work $(work_path)/work -vopt -v +incdir+$(rtl_path)/+$(tb_path)/ -stats=none $(rtl_path)/*.v $(tb_path)/*.v +define+$(test_name)

compile_rtl: 
	@vlog -work $(work_path)/work -vopt -v +incdir+$(rtl_path)/+$(tb_path)/ -stats=none $(rtl_path)/*.v
	
run:	
########################## pass module_name from the command line. Ex. make module_name=tb_washing_machine_controller run
ifeq ($(SHOW_WAVEFORM_FLAG), 1)
	@vsim -coverage $(work_path)/work.$(module_name) -voptargs=+acc -l $(work_path)/transcript_vsim.txt -do "source wave.do; run -all; coverage report -codeAll -cvg -verbose"
else
	@vsim -c $(work_path)/work.$(module_name) -voptargs=+acc -l $(work_path)/transcript_vsim.txt -do "run -all"
endif


################## Target for Makefile help
help:
	@echo ============================================================================ 
	@echo  " ------------------------- Test TARGETS -------------------------------- "
	@echo  " compile_all_rtl => Compile TB and DUT files                             "
	@echo  " run             => Compile TB and DUT files and run the simulation      "
	@echo  "                                                                         "
	@echo  " -------------------- ADMINISTRATIVE TARGETS --------------------------- "
	@echo  " help       => Displays this message                                     "
	@echo  " clean      => Remove all intermediate simv and log files                "
	@echo  "								         "
	@echo  " ---------------------- EMBEDDED SETTINGS ------------------------------ "
	@echo  " -timescale=\"1ns/100ps\"                                                "
	@echo  " -debug_all                                                              "
	@echo ============================================================================  
