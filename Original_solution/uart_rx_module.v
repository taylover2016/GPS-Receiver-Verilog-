//-------------------------
//Design Name: uart_rx
//Function: Receive the serial data
//sent by the tx module of UART
//and send it to the internal registers
//Created on Aug 25, 2019 by Tony Zhang
//-------------------------

//setting timescale
`timescale 1ns/1ns

//port declaration
module uart_rx	#(
	parameter	VERIFY_EVEN = 1'b1,
	parameter	VERIFY_ODD = 1'b0
	)
(
	input	            clk_rx,			//rx module clk
	input	            rst_n,			//rx module rst(active low)
	input	            datain_rx,		//rx module input
	input	            receive_data,	//the signal telling rx module to receive data
	input	            unload_data,	//the signal telling rx module to unload data
	output	reg	[7:0]	rx_out,			//rx module output
	output	reg			rx_busy,		//the signal showing whether rx module is busy
	output	reg 		rx_error		//indicating the data received is wrong
	);

//internal signals declaration
reg [7:0] 	rx_reg;				//internal registers
reg [3:0] 	rx_i;				//a number to select which unit of the registers should be the destination of current input
reg [3:0] 	rx_sample_count;	//a counting number to decide whether the current input is valid
reg 		verify_error;		//verify the data to see whether there's an error
reg 		flag;				//a signal used for verification

//behavior description
always @(posedge clk_rx or negedge rst_n) begin
	if (!rst_n) begin
		// reset rx module
		rx_out<=0;
		rx_busy<=0;
		rx_reg<=0;
		rx_i<=0;
		rx_sample_count<=0;
		verify_error<=0;
		rx_error<=0;
		flag<=0;
	end else begin
		if (unload_data) begin
		//data-unloading command is active
			if (!rx_busy && verify_error==0) begin
				//no data being in the process of storing
				//the data is correctly received
				//ready to unload
				rx_out<=rx_reg;
			end else if (!rx_busy && verify_error==1) begin
				rx_error<=1;
			end
		end
		if (receive_data) begin
		//data-receiving command is active
			if (!rx_busy && !datain_rx) begin
			//rx module is not busy
			//low level detected
			//starting to confirm starting point of frame
				rx_sample_count<=rx_sample_count+1;
				if (rx_sample_count==7) begin
				//check the value of input during the 8th clk period
					if(datain_rx==0) begin
					//starting point valid
						rx_busy<=1;
					end
				end
			end
			if (rx_busy) begin
				rx_sample_count<=rx_sample_count+1;
				if (rx_sample_count==7) begin
				//sample the input and store it if applicable
					if (rx_i>=0 && rx_i<8) begin
					//data valid
					//store the data
						rx_reg[rx_i]<=datain_rx;
						rx_i<=rx_i+1;
					end
					if (rx_i==8) begin
					//run the parity check
						flag=parity_check(rx_reg,VERIFY_EVEN,VERIFY_ODD);
						if (flag==datain_rx) begin
							verify_error<=0;
						end else begin
							verify_error<=1;
						end
						rx_i<=rx_i+1;
					end
					if (rx_i==9) begin
					//stop point of frame
						rx_busy<=0;
						rx_i<=0;
					end
				end
			end
		end
		if (!receive_data) begin
		//receiving process stops
		//reset internal counter and the busy signal
			rx_i<=0;
			rx_busy<=0;
		end
	end
end
//define the parity check function
function parity_check;
	input	[7:0]	data;		//data to be determined
	input			even;		//parity check mode is even
	input			odd;		//parity check mode is odd
	reg 	[3:0]	count;		//data counter
	reg 			xor_temp;	//temp result for xor operation
	begin
		xor_temp=data[0];
		for(count=1;count<8;count=count+1)
		begin
			xor_temp=xor_temp^data[count];
		end
		if (even) begin
			parity_check=xor_temp;
		end else if (odd) begin
			parity_check=~xor_temp;
		end
	end
	endfunction

endmodule