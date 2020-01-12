//--------------------------
//This is the testbench for
//testing the uart pair as
//a tool for transporting GPS data
//--------------------------
//Created on Aug 27, 2019
//by Tony Zhang
//--------------------------
//Let's hope this would work
//--------------------------


module gps_testing;

//signals declaration
reg				clk;				//clk for tx module and rx module
reg				rst_n_tx;			//reset for tx module (active low)
reg				rst_n_rx;			//reset for rx module (active low)

reg 	[7:0]	gps_data;			//gps data to be transported

reg				receive_data_tx;	//data-receiving switch for tx module
reg				send_data_tx;		//data-sending switch for tx module
reg				load_data_tx;		//data-loading switch for tx module
reg				unload_data_tx;		//data-unloading switch for tx module

reg				receive_data_rx;	//data-receiving switch for rx module
reg				send_data_rx;		//data-sending switch for rx module
reg				load_data_rx;		//data-loading switch for rx module
reg				unload_data_rx;		//data-unloading switch for rx module

wire			tx_out;				//data output of tx module
wire			tx_busy;			//the signal showing whether tx module is busy
wire	[7:0]	rx_out;				//data output of rx module
wire			rx_busy;			//the signal showing whether rx module is busy
wire			rx_error;  			//indicating whether the data received is wrong


//signals initialization
initial begin
//clk and reset signals initialization
	clk=0;
	rst_n_rx=1;
	rst_n_tx=1;

//rx module switch signals initialization
	receive_data_rx=1;
	send_data_rx=0;
	load_data_rx=0;
	unload_data_rx=1;

//tx module switch signals initialization
	receive_data_tx=0;
	send_data_tx=1;
	load_data_tx=1;
	unload_data_tx=0;

//reset tx module and rx module
	#3	rst_n_tx=0;
		rst_n_rx=0;
	#3	rst_n_rx=1;
		rst_n_tx=1;

end

//clk generation
always begin
	#5 clk=~clk;
end

//GPS data generation
always begin
				gps_data=8'b00100100;
	#103680		gps_data=8'b01000111;
	#103680		gps_data=8'b01010000;
	#103680		gps_data=8'b01000111;
	#103680		gps_data=8'b01000111;
	#103680		gps_data=8'b01000001;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00110110;
	#103680		gps_data=8'b00110011;
	#103680		gps_data=8'b00111001;
	#103680		gps_data=8'b00110101;
	#103680		gps_data=8'b00110010;
	#103680		gps_data=8'b00101110;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110100;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00110010;
	#103680		gps_data=8'b00101110;
	#103680		gps_data=8'b00110010;
	#103680		gps_data=8'b00110010;
	#103680		gps_data=8'b00111001;
	#103680		gps_data=8'b00111001;
	#103680		gps_data=8'b00110011;
	#103680		gps_data=8'b00110100;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b01001110;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110001;
	#103680		gps_data=8'b00110001;
	#103680		gps_data=8'b00110110;
	#103680		gps_data=8'b00110001;
	#103680		gps_data=8'b00111000;
	#103680		gps_data=8'b00101110;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00111001;
	#103680		gps_data=8'b00110110;
	#103680		gps_data=8'b00111000;
	#103680		gps_data=8'b00110101;
	#103680		gps_data=8'b00110101;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b01000101;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110001;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110100;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110010;
	#103680		gps_data=8'b00101110;
	#103680		gps_data=8'b00110111;
	#103680		gps_data=8'b00111000;
	#103680		gps_data=8'b00111000;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110011;
	#103680		gps_data=8'b00110111;
	#103680		gps_data=8'b00101110;
	#103680		gps_data=8'b00110010;
	#103680		gps_data=8'b00110101;
	#103680		gps_data=8'b00110100;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b01001101;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00110000;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b01001101;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00101100;
	#103680		gps_data=8'b00101010;
	#103680		gps_data=8'b00110111;
	#103680		gps_data=8'b00110001;
	#103680		gps_data=8'b00001101;
	#103680		gps_data=8'b00001010;
	#103680		gps_data=8'b00000000;
end




//calling tx module
uart tx_module (
	.clk(clk),
	.rst_n(rst_n_tx),
	.datain_tx(gps_data),
	.receive_data(receive_data_tx),
	.send_data(send_data_tx),
	.load_data(load_data_tx),
	.unload_data(unload_data_tx),
	.tx_out(tx_out),
	.tx_busy(tx_busy)
	);

//calling rx module
uart rx_module (
	.clk(clk),
	.rst_n(rst_n_rx),
	.datain_rx(tx_out),
	.receive_data(receive_data_rx),
	.send_data(send_data_rx),
	.load_data(load_data_rx),
	.unload_data(unload_data_rx),
	.rx_out(rx_out),
	.rx_busy(rx_busy),
	.rx_error(rx_error)
	);

endmodule