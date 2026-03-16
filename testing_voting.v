`timescale 1ns / 1ps

module tb_digitalVotingMachineFSM;

reg clock;
reg reset;
reg mode;

reg cand1_button;
reg cand2_button;
reg cand3_button;
reg cand4_button;

wire [7:0] leds;

// DUT
digitalVotingMachineFSM dut (
    .clock(clock),
    .reset(reset),
    .mode(mode),
    .cand1_button(cand1_button),
    .cand2_button(cand2_button),
    .cand3_button(cand3_button),
    .cand4_button(cand4_button),
    .leds(leds)
);

// Clock (10 ns period)
always #5 clock = ~clock;


// ---------------------------
// Tasks
// ---------------------------

// Vote for candidate 1
task vote_c1;
begin
    cand1_button = 1;
    #120;
    cand1_button = 0;
    #80;
end
endtask

// Vote for candidate 2
task vote_c2;
begin
    cand2_button = 1;
    #120;
    cand2_button = 0;
    #80;
end
endtask

// Vote for candidate 3
task vote_c3;
begin
    cand3_button = 1;
    #120;
    cand3_button = 0;
    #80;
end
endtask

// Vote for candidate 4
task vote_c4;
begin
    cand4_button = 1;
    #120;
    cand4_button = 0;
    #80;
end
endtask

// Invalid vote (two buttons)
task invalid_vote;
begin
    cand1_button = 1;
    cand2_button = 1;
    #120;
    cand1_button = 0;
    cand2_button = 0;
    #80;
end
endtask

// Show result
task show_result;
begin
    cand1_button = 1; #40; cand1_button = 0; #60;
    cand2_button = 1; #40; cand2_button = 0; #60;
    cand3_button = 1; #40; cand3_button = 0; #60;
    cand4_button = 1; #40; cand4_button = 0; #60;
end
endtask


// ---------------------------
// Test Sequence
// ---------------------------

initial begin

    clock = 0;
    reset = 1;
    mode  = 0;

    cand1_button = 0;
    cand2_button = 0;
    cand3_button = 0;
    cand4_button = 0;

    // Reset
    #20;
    reset = 0;

    // ---------------------------
    // Voting Phase
    // ---------------------------

    vote_c1;
    vote_c1;
    vote_c2;
    vote_c3;
    vote_c4;

    vote_c3;
    vote_c1;
    vote_c2;

    invalid_vote;

    vote_c4;
    vote_c4;
    vote_c3;

    // ---------------------------
    // Switch to Result Mode
    // ---------------------------

    #100;
    mode = 1;

    show_result;

    // ---------------------------
    // Reset Test
    // ---------------------------

    #100;
    reset = 1;
    #40;
    reset = 0;

    #100;

    $finish;

end

endmodule