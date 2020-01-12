//---------------------------
//This is the wrap up of the
//modules involved in a uart
//---------------------------
//Design Name: uart
//Function: transmit the data from output registers
//serially out and receive the data into input registers
//Created on Aug 26, 2019 by Tony Zhang
//---------------------------

//setting timescale
`timescale 1ns/1ns

//port declaration
module uart #(
	parameter baudrate = 115200,
	parameter system_clk_frequency = 100000000,
	parameter VERIFY_EVEN = 1'b1,
	parameter VERIFY_ODD = 1'b0
	)
(
	input				clk,			//system clk
	input				rst_n,			//reset (active low)

	input				datain_rx,		//data input of rx module
	input	[7:0]		datain_tx,		//data input of tx module

	input				receive_data,	//data-receiving switch
	input				send_data,		//data-sending switch
	input				load_data,		//data-loading switch
	input				unload_data,	//data-unloading switch

	output	wire [7:0]	rx_out,			//data output of rx module
	output	wire 		rx_busy,		//the signal showing whether rx module is busy
	output	wire		rx_error,		//indicating the data received is wrong

	output 	wire 		tx_out,			//data output of tx module
	output 	wire 		tx_busy			//the signal showing whether tx module is busy
);

//internal signals declaration
wire 	clk_rx;		//clk for rx module
wire 	clk_tx;		//clk for tx module

//behavior description
divider #(.divisor(system_clk_frequency/(32*baudrate))) div_rx(			//divider generating clk for rx module
	.clk(clk),
	.rst_n(rst_n),
	.clk_divided(clk_rx)
	);
divider #(.divisor(system_clk_frequency/(2*baudrate))) div_tx(			//divider generating clk for tx module
	.clk(clk),
	.rst_n(rst_n),
	.clk_divided(clk_tx)
	);

//module calling
uart_rx rx_module(		//calling rx module
	.clk_rx(clk_rx),
	.rst_n(rst_n),
	.datain_rx(datain_rx),
	.receive_data(receive_data),
	.unload_data(unload_data),
	.rx_out(rx_out),
	.rx_busy(rx_busy),
	.rx_error(rx_error)
	);
uart_tx tx_module (		//calling tx module
 	.clk_tx(clk_tx),
 	.rst_n(rst_n),
 	.datain_tx(datain_tx),
 	.load_data(load_data),
 	.send_data(send_data),
 	.tx_out(tx_out),
 	.tx_busy(tx_busy)
 	);

endmodule

//-----------------------
//clk dividing module starts here
//-----------------------

//setting timescale
`timescale 1ns/1ns

//port declaration
module divider #(parameter divisor=27)
(
	input			clk,			//clk to be divided
	input			rst_n,			//reset (active low)
	output	reg		clk_divided		//divided clk
);

//internal signal declaration
reg [9:0] count;

//behavior description
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		// reset clk divider
		clk_divided<=0;
		count<=0;
	end else if (count!=(2*divisor-1)) begin
		count<=count+1;
		if (count<divisor) begin
			clk_divided<=0;
		end else begin
			clk_divided<=1;
		end
	end else begin
		count<=0;
		clk_divided<=1;
	end
end
endmodule