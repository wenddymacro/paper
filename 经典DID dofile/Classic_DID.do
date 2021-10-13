************************************************************
* 许文立，2021-10，安徽大学 & 西蒙菲莎大学，xuweny87@hotmail.com
* 《应用计量经济学讲稿》配套dofile
*
* 一、经典2×2DID
************************************************************

clear      // 清除stata已存在的数据
local units = 2
local start = 1
local end   = 2

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen NU     = seq(), b(`time')  
egen Period      = seq(), f(`start') t(`end')   

sort NU Period
xtset NU Period    // 声明面板数据类型

lab var NU "Panel variable"
lab var Period  "Time  variable"

* 创建处理变量T和结果变量y
gen T = NU==2 & Period==2    //双等号表示恒等于，即处理发生在第二个id，第二期，这时T=1，其它所有情况T=0

gen btrue = cond(T==1, 3, 0) 	     //cond表示当T==1为真时，btru这个变量才赋值为3，否则赋值为0
	
gen Y = NU + 3*Period + btrue*T    //利用这个函数来生成结果变量y的数据


lab de prepost1 1 "前" 2 "后"
lab val Period prepost1

* 可视化数据

twoway ///
	(connected Y Period if NU==1) ///
	(connected Y Period if NU==2) ///
		,	///
		legend(order(1 "NU=黄陂区" 2 "NU=江夏区")) ///
		xlabel(1 2, valuelabel) ylabel(4(1)11)

		
		
* 面板数据回归

xtreg Y T Period,fe
		
* 常用的双向固定效应命令reghdfe
* 如果没有安装这个程序包，请先安装：
* ssc install reghdfe,replace

reghdfe Y T, absorb(NU Period)



**********************************************
* 二、多期的Periods×2DID
**********************************************

clear      // 清除stata已存在的数据
local units = 2
local start = 1
local end   = 20

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen NU     = seq(), b(`time')  
egen Period      = seq(), f(`start') t(`end')   

sort NU Period
xtset NU Period    // 声明面板数据类型

lab var NU "Panel variable"
lab var Period  "Time  variable"

* 假设在第5期之后，有新校区假设

* 创建处理变量T和结果变量y
gen T = NU==2 & Period>=5    //双等号表示恒等于，即处理发生在第二个id，第5期，这时T=1，其它所有情况T=0

lab var T "Treated"


gen btrue = cond(T==1, 4, 0) 	     //cond表示当T==1为真时，btru这个变量才赋值为3，否则赋值为0
	
gen Y = NU + Period + btrue*T    //利用这个函数来生成结果变量y的数据

lab var Y "Outcome variable"

* 可视化数据

twoway ///
	(connected Y Period if NU==1) ///
	(connected Y Period if NU==2) ///
		,	///
		xline(5) ///
		legend(order(1 "NU=黄陂区" 2 "NU=江夏区")) ///
		ylabel(4(2)26)


* 面板数据回归

xtreg Y T Period,fe
		
* 常用的双向固定效应命令reghdfe
* 如果没有安装这个程序包，请先安装：
* ssc install reghdfe,replace

reghdfe Y T, absorb(NU Period)



**********************************************
* 三、多个组群-多期的Periods×NU DID
**********************************************

clear      // 清除stata已存在的数据
local units = 3
local start = 1
local end   = 20

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen NU     = seq(), b(`time')  
egen Period      = seq(), f(`start') t(`end')   

sort NU Period
xtset NU Period    // 声明面板数据类型

lab var NU "Panel variable"
lab var Period  "Time  variable"

* 假设在第5期之后，有新校区假设

* 创建处理变量T和结果变量y
gen T = 0
replace T = 1 if NU>=2 & Period>=5    //处理发生在第二和三个id，第5期，这时T=1，其它所有情况T=0

lab var T "Treated"


cap drop Y

gen Y = 0

replace Y = cond(T==1, 2, 0) if NU==2

replace Y = cond(T==1, 4, 0) if NU==3

lab var Y "Outcome variable"	

twoway ///
	(connected Y Period if NU==1) ///
	(connected Y Period if NU==2) ///
	(connected Y Period if NU==3) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)20) ///
		legend(order(1 "NU=1" 2 "NU=2" 3 "NU=3"))

* 面板数据回归

xtreg Y T Period,fe
		
* 常用的双向固定效应命令reghdfe
* 如果没有安装这个程序包，请先安装：
* ssc install reghdfe,replace

reghdfe Y T, absorb(NU Period)



* 加入一些时间趋势和个体效应

cap drop Y

gen Y = 0

replace Y = NU + Period + cond(T==1, 0, 0) if NU==1
replace Y = NU + Period + cond(T==1, 2, 0) if NU==2
replace Y = NU + Period + cond(T==1, 4, 0) if NU==3

lab var Y "Outcome variable"

* 可视化数据

twoway ///
	(connected Y Period if NU==1) ///
	(connected Y Period if NU==2) ///
	(connected Y Period if NU==3) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)10) ///
		legend(order(1 "NU=1" 2 "NU=2" 3 "NU=3"))	


* 面板数据回归

xtreg Y T Period,fe
		
* 常用的双向固定效应命令reghdfe
* 如果没有安装这个程序包，请先安装：
* ssc install reghdfe,replace

reghdfe Y T, absorb(NU Period)

* 我们在上述回归中控制平行趋势假设

reg Y T				// 不控制任何因素
reg Y T i.Period			// 仅仅控制时间固定效应
reg Y T i.NU		// 仅仅控制个体固定效应
reg Y T i.Period i.NU	// 双向固定效应(正确!)		
		
**********************************************
* 四、多个组群-多期、不同处理时点的Periods×NU DID
**********************************************

clear      // 清除stata已存在的数据
local units = 3
local start = 1
local end   = 20

local time = `end' - `start' + 1
local obsv = `units' * `time'
set obs `obsv'

egen NU     = seq(), b(`time')  
egen Period      = seq(), f(`start') t(`end')   

sort NU Period
xtset NU Period    // 声明面板数据类型

lab var NU "Panel variable"
lab var Period  "Time  variable"

* 假设在第5期之后，有新校区假设

* 创建处理变量T和结果变量y
gen T = 0
replace T = 1 if NU==2 & Period>=5   //处理发生在第二个id，第5期，这时T=1，其它所有情况T=0
replace T = 1 if NU==3 & Period>=10   //处理发生在第三个id，第10期，这时T=1，其它所有情况T=0


lab var T "Treated"


cap drop Y

gen Y = 0

replace Y = cond(T==1, 2, 0) if NU==2

replace Y = cond(T==1, 4, 0) if NU==3

lab var Y "Outcome variable"	

twoway ///
	(connected Y Period if NU==1) ///
	(connected Y Period if NU==2) ///
	(connected Y Period if NU==3) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)20) ///
		legend(order(1 "NU=1" 2 "NU=2" 3 "NU=3"))

* 面板数据回归

xtreg Y T Period,fe
		
* 常用的双向固定效应命令reghdfe
* 如果没有安装这个程序包，请先安装：
* ssc install reghdfe,replace

reghdfe Y T, absorb(NU Period)



* 加入一些时间趋势和个体效应

cap drop Y

gen Y = 0

replace Y = NU + Period + cond(T==1, 0, 0) if NU==1
replace Y = NU + Period + cond(T==1, 2, 0) if NU==2
replace Y = NU + Period + cond(T==1, 4, 0) if NU==3

lab var Y "Outcome variable"

* 可视化数据

twoway ///
	(connected Y Period if NU==1) ///
	(connected Y Period if NU==2) ///
	(connected Y Period if NU==3) ///
		,	///
		xline(4.5) ///
		xlabel(1(1)20) ///
		legend(order(1 "NU=1" 2 "NU=2" 3 "NU=3"))	


* 面板数据回归

xtreg Y T Period,fe
		
* 常用的双向固定效应命令reghdfe
* 如果没有安装这个程序包，请先安装：
* ssc install reghdfe,replace

reghdfe Y T, absorb(NU Period)
	
	
	
	
	
	
	
	
	
	
