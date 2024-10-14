vlog cache_memory.v cache_controller.v Main_Memory.v cache_top.v PC.v reg_file.v instruction_memory.v ALU_Decoder.v Main_Decoder.v Control_Unit.v ALU.v instruction_decoder.v extend.v shared_pkg.sv instruction_trans.sv coverage_pkg.sv scoreboard_pkg.sv RISC_top.sv RISC_if.sv Risc_tb.sv RISC_monitor.sv risc_v_processor.sv +define+SIM +cover

vsim -voptargs=+acc work.RISC_top -classdebug

add wave -position insertpoint  \
sim:/RISC_top/R_if/* \
sim:/RISC_top/RISC_DUT/* \
sim:/RISC_top/RISC_DUT/RegFile/file \
sim:/RISC_top/RISC_DUT/MemSystem/main_mem/ram \
sim:/RISC_top/RISC_DUT/MemSystem/cache_mem/DataBlock_m \
sim:/RISC_top/RISC_DUT/MemSystem/cache_mem/cache

add wave -position insertpoint  \
sim:/RISC_top/RISC_DUT/MemSystem/word_address \
sim:/RISC_top/RISC_DUT/MemSystem/data_in \
sim:/RISC_top/RISC_DUT/MemSystem/data_out \
sim:/RISC_top/RISC_DUT/MemSystem/ready \
sim:/RISC_top/RISC_DUT/MemSystem/read \
sim:/RISC_top/RISC_DUT/MemSystem/read_mem \
sim:/RISC_top/RISC_DUT/MemSystem/write_mem \
sim:/RISC_top/RISC_DUT/MemSystem/update \
sim:/RISC_top/RISC_DUT/MemSystem/refill \
sim:/RISC_top/RISC_DUT/MemSystem/tag \
sim:/RISC_top/RISC_DUT/MemSystem/index \
sim:/RISC_top/RISC_DUT/MemSystem/offset \
sim:/RISC_top/RISC_DUT/MemSystem/main_mem_block \
sim:/RISC_top/RISC_DUT/MemSystem/controller/lookup_table \
sim:/RISC_top/RISC_DUT/MemSystem/controller/hit \
sim:/RISC_top/RISC_DUT/MemSystem/controller/current_state \
sim:/RISC_top/RISC_DUT/MemSystem/controller/next_state \
sim:/RISC_top/RISC_DUT/MemSystem/main_mem/counter_value_read \
sim:/RISC_top/RISC_DUT/MemSystem/main_mem/counter_value_write \
sim:/RISC_top/RISC_DUT/MemSystem/main_mem/continue_read \
sim:/RISC_top/RISC_DUT/MemSystem/main_mem/continue_write

add wave -position insertpoint  \
sim:/RISC_top/RISC_MON/R_txn \
sim:/RISC_top/RISC_MON/R_tcov \
sim:/RISC_top/RISC_MON/R_cov/R_cvg_txn \
sim:/RISC_top/RISC_MON/R_score \
sim:/shared_pkg::c_count_ALURes \
sim:/shared_pkg::e_count_ALURes \
sim:/shared_pkg::c_count_PCNext \
sim:/shared_pkg::e_count_PCNext \
sim:/shared_pkg::c_count_RD_m \
sim:/shared_pkg::e_count_RD_m \
sim:/shared_pkg::c_count_MemRd \
sim:/shared_pkg::e_count_MemRd \
sim:/shared_pkg::c_count_MemWr \
sim:/shared_pkg::e_count_MemWr \
sim:/shared_pkg::c_count_Stall \
sim:/shared_pkg::e_count_Stall

coverage save RISC_top.ucdb -onexit

run -all
