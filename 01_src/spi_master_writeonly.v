module spi_master_writeonly #(
    parameter SCLK = 20
)(
    input wire clk,
    input wire rst_n,
    input wire start_transfer,
    input wire [3:0] address,
    input wire [15:0] data_to_send,
    output reg sclk = 0,
    output reg cs_n = 1,
    output reg mosi = 0
);
localparam  cycle = 200/SCLK;
reg [4:0] clk_cnt=0;
reg sclk_next =0;
reg [31:0] shift_reg=0;
reg [4:0] bit_counter=0;
reg state=0;

// States for SPI state machine
localparam IDLE = 1'b0;
localparam TRANSFER = 1'b1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        shift_reg <= 32'b0;
        bit_counter <= 5'b00000;
        cs_n <= 1'b1;
        sclk <= 1'b0;
        clk_cnt <= 5'b0;
    end else begin
        case (state)
            IDLE: begin
                if (start_transfer) begin
                    state <= TRANSFER;
                    shift_reg <= {12'h001, address, data_to_send};
                    bit_counter <= 5'b11111;
                    cs_n <= 1'b0;
                end
            end
            TRANSFER: begin
                sclk_next <= sclk;
                if (clk_cnt == cycle/2-1) begin
                    sclk <= ~sclk;
                    clk_cnt <= 5'b0;
                end
                else begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                if ({sclk,sclk_next} == 2'b01) begin
                    mosi <= shift_reg[31];
                    shift_reg <= {shift_reg[30:0], 1'b0};
                    bit_counter <= bit_counter - 1'b1;
                    if (bit_counter == 0) begin
                        state <= IDLE;
                        cs_n <= 1'b1;
                    end
                end
            end
        endcase
    end
end

endmodule
