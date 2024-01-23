module mul(
    input clk,
    input rst,
    input [2:0] start,
    input [31:0] A,
    input [31:0] B,
    output reg busy,
    output reg [31:0] hi,
    output reg [31:0] lo
);
    reg [31:0] cnt;
    reg [31:0] limit;
    wire [63:0] mult;
    wire [63:0] multu;
    
    assign mult = $signed(A)*$signed(B);
    assign multu =A*B;

    always @(posedge clk) begin
        if (rst==1) begin
            hi<=0;
            lo<=0;
            busy<=0;
            cnt<=0;
            limit<=0;
        end
        else begin
            if(busy&&cnt<limit-1)begin
                cnt<=cnt+1;
            end
            else if(cnt==limit-1)begin
                cnt<=0;
                busy<=0;
            end
            else begin
                if(start==3'd1) begin
                    busy<=1;
                    limit<=5;
                    hi<=mult[63:32];
                    lo<=mult[31:0];
                end
                else if(start==3'd2) begin
                    busy<=1;
                    limit<=5;
                    hi<=multu[63:32];
                    lo<=multu[31:0];
                end
                else if(start==3'd3) begin
                    busy<=1;
                    limit<=10;
                    hi<=$signed(A)%$signed(B);
                    lo<=$signed(A)/$signed(B);
                end
                else if(start==3'd4) begin
                    busy<=1;
                    limit<=10;
                    hi<=A%B;
                    lo<=A/B;
                end
                else if(start==3'd5) begin
                    hi<=A;
                end
                else if(start==3'd6) begin
                    lo<=A;
                end
            end
        end
    end
endmodule