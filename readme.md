## 使用说明
1. 先获取硬综项目资源包，项目地址为https://gitee.com/cyyself/CO-lab-material-CQU/tree/2021 （如果已经有了则跳过这一步）
2. sram-soc的外部顶层文件已经在上面项目中提供，将myCPU文件夹拷贝至CO-lab-material-CQU/test/func_test_v0.01_n4ddr/soc_sram_func/rtl目录下
3. 此时使用的工程文件在CO-lab-material-CQU\test\func_test_v0.01_n4ddr\soc_sram_func\run_vivado\project_1下，打开并在vivado中添加myCPU下的所有.v文件
4. 直接运行仿真，观察波形图及控制台结果
## 注意事项
1. 本项目只完成了前52条指令，不包括特权及异常处理
2. 本项目适用于功能测试，不适用于独立测试（不过一般而言功能测试通过了就不会去检查独立测试）
3. 本项目的数据通路是有问题的，但由于能通过前64个测试点，所以未做更改
4. 本项目提供了说明文档，可帮助您更快理解其数据通路
