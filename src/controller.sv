`timescale 1ns/1ps

module controller (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start_inference,
    input  logic       load_weight_cmd,
    input  logic       clear_acc_cmd,

    output logic       busy,
    output logic       done,
    output logic [2:0] state_out,
    output logic       weight_wr_en,
    output logic       pe_eval_en,
    output logic       accum_en,
    output logic       accum_clear
);

    typedef enum logic [2:0] {
        S_IDLE  = 3'd0,
        S_LOAD  = 3'd1,
        S_COMP  = 3'd2,
        S_ACCUM = 3'd3,
        S_DONE  = 3'd4
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            S_IDLE: begin
                if (load_weight_cmd) begin
                    next_state = S_LOAD;
                end else if (start_inference) begin
                    next_state = S_COMP;
                end
            end

            S_LOAD: begin
                next_state = S_IDLE;
            end

            S_COMP: begin
                next_state = S_ACCUM;
            end

            S_ACCUM: begin
                next_state = S_DONE;
            end

            S_DONE: begin
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    assign state_out    = current_state;
    assign busy         = (current_state != S_IDLE);
    assign done         = (current_state == S_DONE);
    assign weight_wr_en = (current_state == S_LOAD);
    assign pe_eval_en   = (current_state == S_COMP);
    assign accum_en     = (current_state == S_ACCUM);
    assign accum_clear  = clear_acc_cmd || (current_state == S_IDLE && start_inference);

endmodule
