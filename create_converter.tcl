create_converter morse_converter ./morse_converter -part xc7a35tcpg236-1
add_files [glob ./src/rtl/*.vhd]
add_files [glob ./src/mem/*.coe]
add_files [glob ./constraints/*.xdc]
update_compile_order -fileset sources_1
