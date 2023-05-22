module spi_top (
    input wire clk,
    input wire rst_n,
    input wire start_transfer,
    input wire [3:0] address,
    input wire [15:0] data_to_send,
    output wire sclk,
    output wire mosi
);

localparam [3:0] CALIBRATION_ADDR                	    = 4'b0000; // when calibration, tie 15th bit to 1
localparam [3:0] CONFIGRATION_ADDR               	    = 4'b0001;
localparam [3:0] I_OFFSET_ADDR                   	    = 4'b0010;
localparam [3:0] I_FSCAl_VOLTAGE_ADDR            	    = 4'b0011;
localparam [3:0] EXTEND_CONFIGRATION_ADDR        	    = 4'b1001;
localparam [3:0] Q_OFFSET_ADDR                   		= 4'b1010;
localparam [3:0] Q_FSCAl_VOLTAGE_ADDR            	    = 4'b1011;
localparam [3:0] SAMP_CLK_PHASE_FINE_ADDR        	    = 4'b1110;
localparam [3:0] SAMP_CLK_PHASE_COARSE_ADDR      	    = 4'b1111;

localparam [15:0] CALIBRATION_VALUE					= 16'h8fff; // when calibration, tie 15th bit to 1
localparam [15:0] CONFIGRATION_VALUE					= 16'hbaff;	// 16'b1011 1010 1111 1111
localparam [15:0] I_OFFSET_VALUE						= 16'h003f; // 16'b0000 0000 0011 1111
localparam [15:0] I_FSCAl_VOLTAGE_VALUE				= 16'h807f; // 16'b1000 0000 0111 1111
localparam [15:0] EXTEND_CONFIGRATION_VALUE			= 16'h0400; // 16'b0000 0100 0000 0000
localparam [15:0] Q_OFFSET_VALUE						= 16'h003f; // 16'b0000 0000 0011 1111
localparam [15:0] Q_FSCAl_VOLTAGE_VALUE				= 16'h807f; // 16'b1000 0000 0111 1111
localparam [15:0] SAMP_CLK_PHASE_FINE_VALUE			= 16'h00ff; // 16'b0000 0000 1111 1111 
localparam [15:0] SAMP_CLK_PHASE_COARSE_VALUE			= 16'h003f; // 16'b0000 0000 0011 1111
reg [4:0] reg_counter=0;


reg [3:0] spi_address;
reg [15:0] spi_data_to_send;
wire cs_n;
reg cs_n_d;
reg initial_en;

// 1. 参数初始化状态机		       done
// 2. 通过vio进行参数调试，输入后
// 3. OBUF数据读取
// 4. 


spi_master_writeonly 
spi_master_writeonly_dut (
  .clk (clk ),
  .rst_n (rst_n ),
  .start_transfer (initial_en ),
  .address (spi_address ),
  .data_to_send (spi_data_to_send ),
  .sclk (sclk ),
  .cs_n (cs_n ),
  .mosi  ( mosi)
);
always@(posedge clk)
	cs_n_d <= cs_n;

// reg_counter only valid if start_transfer is high when reset
always @(negedge cs_n_d) begin
    if (initial_en) begin
		if(reg_counter == 8) 
			reg_counter <= 'b0;
		else
        	reg_counter <= reg_counter + 1'b1;
    end
	else
		reg_counter <= 'b0;
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		initial_en = 1'b1;
	else if  (reg_counter == 8)
		initial_en = 1'b0;
	end

	
always @(*) begin
	case(reg_counter) 
		0: begin
			spi_address 		= 	CALIBRATION_ADDR;
			spi_data_to_send 	=	CALIBRATION_VALUE;
		end
		1: begin
			spi_address 		= 	CONFIGRATION_ADDR;
			spi_data_to_send 	=	CONFIGRATION_VALUE;
		end
		2: begin 
			spi_address 		= 	I_OFFSET_ADDR;
			spi_data_to_send 	=	I_OFFSET_VALUE;
		end
		3: begin
			spi_address 		= 	I_FSCAl_VOLTAGE_ADDR;
			spi_data_to_send 	=	I_FSCAl_VOLTAGE_VALUE;
		end 
		4: begin
			spi_address 		= 	EXTEND_CONFIGRATION_ADDR;
			spi_data_to_send 	=	EXTEND_CONFIGRATION_VALUE;
		end
		5: begin 
			spi_address 		= 	Q_OFFSET_ADDR;
			spi_data_to_send 	=	Q_OFFSET_VALUE;
		end
		6: begin
			spi_address 		= 	Q_FSCAl_VOLTAGE_ADDR;
			spi_data_to_send 	=	Q_FSCAl_VOLTAGE_VALUE;
		end
		7: begin
			spi_address 		= 	SAMP_CLK_PHASE_FINE_ADDR;
			spi_data_to_send 	=	SAMP_CLK_PHASE_FINE_VALUE;
		end
		8: begin
			spi_address 		= 	SAMP_CLK_PHASE_COARSE_ADDR;
			spi_data_to_send 	=	SAMP_CLK_PHASE_COARSE_VALUE;
		end
		default: begin
			spi_address			= 	'b0;
			spi_data_to_send 	= 	'b0;
		end
	endcase   
end
endmodule
