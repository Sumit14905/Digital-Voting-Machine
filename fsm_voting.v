`timescale 1ns / 1ps

module digitalVotingMachineFSM (
    input clock,
    input reset,
    input mode,      
    input cand1_button,
    input cand2_button,
    input cand3_button,
    input cand4_button,
    output [7:0] leds
);

    parameter IDLE     = 3'b000;
    parameter VOTING   = 3'b001;
    parameter REGISTER = 3'b010;
    parameter LOCKOUT  = 3'b011;
    parameter RESULT   = 3'b100;

    reg [2:0] current_state, next_state;

    reg b1, b2, b3, b4;
    always @(posedge clock) begin
        b1 <= cand1_button;
        b2 <= cand2_button;
        b3 <= cand3_button;
        b4 <= cand4_button;
    end

    wire single_press;
    assign single_press = (b1 + b2 + b3 + b4) == 1;

    wire v1, v2, v3, v4;
    buttonControl bc1 (clock, reset, b1, v1);
    buttonControl bc2 (clock, reset, b2, v2);
    buttonControl bc3 (clock, reset, b3, v3);
    buttonControl bc4 (clock, reset, b4, v4);

    wire [7:0] c1_votes, c2_votes, c3_votes, c4_votes;
    voteLogger logger (
        .clock(clock),
        .reset(reset),
        .mode(mode),
        .cand1_vote_valid(v1 & single_press),
        .cand2_vote_valid(v2 & single_press),
        .cand3_vote_valid(v3 & single_press),
        .cand4_vote_valid(v4 & single_press),
        .cand1_vote_recvd(c1_votes),
        .cand2_vote_recvd(c2_votes),
        .cand3_vote_recvd(c3_votes),
        .cand4_vote_recvd(c4_votes)
    );

    // Simplified Reset Logic
    always @(posedge clock) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE:     if (mode) next_state = RESULT; 
                      else if (single_press) next_state = VOTING;
            VOTING:   if (v1 || v2 || v3 || v4) next_state = REGISTER;
            REGISTER: next_state = LOCKOUT;
            LOCKOUT:  if (!(b1 || b2 || b3 || b4)) next_state = IDLE;
            RESULT:   if (!mode) next_state = IDLE;
            default:  next_state = IDLE;
        endcase
    end

   modeControl display (
    .clock(clock),
    .reset(reset),
    .mode(mode),

    .cand1_button(b1),
    .cand2_button(b2),
    .cand3_button(b3),
    .cand4_button(b4),

    .cand1_vote_recvd(c1_votes),
    .cand2_vote_recvd(c2_votes),
    .cand3_vote_recvd(c3_votes),
    .cand4_vote_recvd(c4_votes),

    .leds(leds)
);
endmodule