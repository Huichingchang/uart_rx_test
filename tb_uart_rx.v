`timescale 1ns/1ps
module tb_uart_rx;

	reg clk;
	reg rst;
	reg rx;
	wire [7:0] data;
	wire done;
	
	//實例化UART接收模組
	uart_rx uut(
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.data(data),
		.done(done)
	);
	
	//產生 100MHz時鐘(週期10ns)
	always #5 clk = ~clk; //100MHz clock
	
	//傳送UART資料(start + 8 data + stop)
	task send_uart_byte;
		input [7:0] din;
		integer i;
		begin
			rx = 0; //Start bit
			#(16*10); //160ns (16x oversampling)
			
			for (i = 0; i < 8; i = i + 1) begin
				rx = din[i];
				#(16*10); //每bit間格
			end
			
			rx = 1; //Stop bit
			#(16*10);
		end
	endtask
	
	//初始化與測試流程
	initial begin
		clk = 0;
		rst = 1;
		rx = 1; //UART idle狀態為high
		#100;
		rst = 0;
		
		#200;
		send_uart_byte(8'hA5); //傳送資料0XA5
		
		@(posedge done);
		$display("[Time %0t ns] Received Byte = %h", $time, data);
		
		#100;
		$stop;
	end
endmodule