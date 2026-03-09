copy /b gyrussk.1 + gyrussk.2 + gyrussk.3 + gyrussk.4 gyruss_cpu.bin
copy /b gyrussk.1a + gyrussk.2a gyruss_sndcpu.bin
rem copy /b gyrussk.6 + gyrussk.5 + gyrussk.8 + gyrussk.7 gyruss_gfx1.bin

make_vhdl_prom gyrussk.pr1 prom_gyruss_slt.vhd
make_vhdl_prom gyrussk.pr2 prom_gyruss_clt.vhd
make_vhdl_prom gyrussk.pr3 prom_gyruss_pal.vhd

make_vhdl_prom gyrussk.3a prom_gyruss_audio.vhd

make_vhdl_prom gyrussk.6 prom_gyruss_gfx1_1.vhd
make_vhdl_prom gyrussk.5 prom_gyruss_gfx1_2.vhd
make_vhdl_prom gyrussk.8 prom_gyruss_gfx1_3.vhd
make_vhdl_prom gyrussk.7 prom_gyruss_gfx1_4.vhd

make_vhdl_prom gyruss_cpu.bin prom_gyruss_cpu.vhd
rem make_vhdl_prom gyruss_gfx1.bin prom_gyruss_gfx1.vhd
make_vhdl_prom gyrussk.4 prom_gyruss_gfx2.vhd
make_vhdl_prom gyruss_sndcpu.bin prom_gyruss_sndcpu.vhd
make_vhdl_prom gyrussk.9 prom_gyruss_sub.vhd

pause