//------------------------------
//This is my solution to Ex1
//Let's hope everything would work
//------------------------------
//Design Name: uart_tx
//Function: Send the data in the
//register serially out
//Created on Aug 23,2019
//------------------------------

//setting timescale
`timescale 1ns/1ns

//port declaration
module uart_tx	#(
	parameter VERIFY_EVEN = 1'b1,
	parameter VERIFY_ODD = 1'b0
	)
  (
  	input	    clk_tx,	        //tx module clk
  	input	    rst_n,	        //tx module rst(active low)
  	input [7:0] datain_tx,	    //tx data input
  	input	    load_data,	    //the signal telling tx module to load data
  	input	    send_data,	    //the signal telling tx module to send data
  	output reg	tx_out,			//tx module output
  	output reg	tx_busy			//the signal showing whether tx module is busy
  	);

//internal signals declaration
reg [7:0]	tx_reg; 	//internal registers
reg [3:0]	tx_i; 		//a number to select which unit of the signal should be the current output
reg 		tx_parity;	//the signal to verify the data

//behavior description
always @(posedge clk_tx or negedge rst_n) begin
	if (!rst_n) begin
		// reset tx module
		tx_out<=1;
		tx_busy<=0;
		tx_reg<=0;
		tx_i<=0;
		tx_parity<=0;
	end else begin
		if (load_data) begin
		//data-loading command is active
		   if (!tx_busy) begin
		   //no data stored in internal registers
		   //ready to load data
		   	 tx_reg=datain_tx;
		   	 tx_busy<=1;
		   	 tx_parity<=parity(tx_reg,VERIFY_EVEN,VERIFY_ODD);
		   end
	    end
	    if (tx_busy && send_data) begin
	    //data stored in internal registers
	    //data-sending command active
	    	case(tx_i)
	    	0:begin
	    	//starting point generation
	    		tx_out<=0;
	    		tx_i<=tx_i+1;
	    	end
	    	1,2,3,4,5,6,7,8:begin
	    	//data-bit generation
	    		tx_out<=tx_reg[tx_i-1];
	    		tx_i<=tx_i+1;
	    	end
	    	9:begin
	    	//parity-bit generation
	    		tx_out<=tx_parity;
	    		tx_i<=tx_i+1;
	    	end
	    	10:begin
	    	//stopping point generation
	    		tx_out<=1;
	    		tx_busy<=0;
	    		tx_i<=0;
	    	end
	    	default:tx_out<=1;
	    	endcase
	    end
	    if (!send_data) begin
	    //sending process stops
	    //reset the output and internal counter
	    	tx_i<=0;
	    	tx_out<=1;
	    end
	end
end

//define the function for determine the parity
function parity;
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
			parity=xor_temp;
		end else if (odd) begin
			parity=~xor_temp;
		end
	end
	endfunction
endmodule