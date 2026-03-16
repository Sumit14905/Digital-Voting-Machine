`timescale 1ns / 1ps

module modeControl(
    input clock,
    input reset,
    input mode,

    input cand1_button,
    input cand2_button,
    input cand3_button,
    input cand4_button,

    input [7:0] cand1_vote_recvd,
    input [7:0] cand2_vote_recvd,
    input [7:0] cand3_vote_recvd,
    input [7:0] cand4_vote_recvd,

    output reg [7:0] leds
);

reg [31:0] counter;

always @(posedge clock or posedge reset)
begin
    if(reset) 
    begin
        leds <= 8'b00000000;
        counter <= 0;
    end

    else 
    begin

        // -------- Voting Mode --------
        if(mode == 0) 
        begin
            if(counter < 50)
            begin
                counter <= counter + 1;
                leds <= 8'hFF;     // vote acknowledgement
            end
            else
            begin
                leds <= 8'h00;
                counter <= 0;
            end
        end

        // -------- Result Mode --------
        else
        begin
            counter <= 0;

            if(cand1_button)
                leds <= cand1_vote_recvd;

            else if(cand2_button)
                leds <= cand2_vote_recvd;

            else if(cand3_button)
                leds <= cand3_vote_recvd;

            else if(cand4_button)
                leds <= cand4_vote_recvd;

            else
                leds <= 8'b00000000;
        end

    end
end

endmodule