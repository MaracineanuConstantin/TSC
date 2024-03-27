/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
// aici e output/input si in DUT e declarat invers, input/output

// folosit cu fopen
// regression.bat => call run_test.bat 5 5 1 1 case_inc gui
module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;

  static int passed_tests = 0;
  static int failed_tests = 0;
  static int total_tests = 0;

  parameter WR_NR = 50;
  parameter RD_NR = 50;
    
  parameter WRITE_ORDER = 1;  // 1 = crescator, 2 = descrescator, 3 = random
  parameter READ_ORDER = 1;   // 1 = crescator, 2 = descrescator, 3 = random
  

  int seed = 555;
  instruction_t  iw_reg_test [0:31];  // an array of instruction_word structures

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU DON'T ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    // repeat (3) begin MARACINEANU CONSTANTIN MODIFICARE
    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<RD_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if(READ_ORDER == 1)
        begin
          read_pointer = i % 32;
        end
      else if (READ_ORDER == 2)
        begin
          read_pointer = 31 - (i % 32 );
        end
      else if (READ_ORDER == 3)
        begin
          read_pointer = $unsigned($random) % 32;
        end
      @(negedge clk) print_results;
      check_result;

      $display("There are %0d passed results and %0d failed results out of %0d total tests.", passed_tests, failed_tests, total_tests);
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU DON'T***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    
    // Write_order = 1 - crescator, Write_order = 2 - descrescator, Write_order = 3 - random
    if(WRITE_ORDER==1)
      begin
        static int temp = 0;     // static pastreaza valoarea in memorie si poate fi modificata din alte locuri
        write_pointer = temp++;
      end
    else if (WRITE_ORDER==2)
      begin
      static int temp = 31;
      write_pointer = temp--;
      end
    else if (WRITE_ORDER==3)
      begin
      static int temp = $unsigned($random) % 32;
      end

    operand_a     = $random(seed)%16;                 // between -15 and 15
    operand_b     = $unsigned($random)%16;            // between 0 and 15 - unsigned converteste din nr negativ in nr pozitiv
    opcode        = opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    iw_reg_test[write_pointer] = '{opcode, operand_a, operand_b, 'b0};
    
    $display("La finalul randomize transaction valorile sunt: op_a = %0d, op_b = %0d, opcode = %0d, time = %t\n", operand_a, operand_b, opcode, $time);
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  rezultat = %0d\n", instruction_word.rezultat);

  endfunction: print_results

  function void check_result;
    result_t result;
    case(iw_reg_test[read_pointer].opc)
          	ZERO:  result = {64{1'b0}};
            PASSA: result = iw_reg_test[read_pointer].op_a;
            PASSB: result = iw_reg_test[read_pointer].op_b;
            ADD:   result = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
            SUB:   result = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
            MULT:  result = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
            DIV:   begin
                    if(iw_reg_test[read_pointer].op_b === 0)
                      begin
                        $display("a fost intampinata o exceptie, divizie cu 0");
                        result = 0;
                      end
                    else
                    result = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
                  end

            MOD:   result = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
    endcase

    $display("valoarea la instruction_word.rezultat este %0d si valoarea in iw_reg_test este %0d", instruction_word.rezultat, result);
    if(instruction_word.rezultat === result)
    begin
      passed_tests++;
      total_tests++;
      $display("rezultatul este corect");
    end
    else
    begin
      failed_tests++;
      total_tests++;
      $display("rezultatul este incorect");
    end


  fopen("../reports/regression_transcript")

  endfunction: check_result

endmodule: instr_register_test
