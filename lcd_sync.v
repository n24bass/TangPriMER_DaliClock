
module lcd_sync
  #(
    //display image at pos
    parameter IMG_W = 100,  // LCD Width
    parameter IMG_H = 100  // LCD Height
    )
   (
    input wire 	       clk, // source LCD clock
    input wire 	       rest_n, // reset
    // 
    output wire        lcd_clk, // out LCD clock
    output wire        lcd_pwm, // out LCD backlight
    output wire        lcd_de, // LCD DE = SYNC
    output wire [10:0] xofs,
    output wire [10:0] yofs,
    output wire [15:0] addr
    );
   
   // 800*480
   localparam TFT_H = 800;  // Width
   localparam TFT_V = 480;  // Height
   
   localparam thb = 256;
   localparam th = TFT_H + thb; // 1056 + thb;

   localparam tvb = 45;
   localparam tv = TFT_V + tvb; // 525 + tvb;
   // 
   
   reg [10:0] 	       counter_hs;
   reg [10:0] 	       counter_vs;

   always@ (posedge clk) begin
      if (rest_n == 1'b0) begin
	 counter_hs <= 0;
	 counter_vs <= 0;
      end else begin
	 if (counter_hs == th) begin
	    if (counter_vs == tv)
	      counter_vs <= 0;
	    else
	      counter_vs <= counter_vs + 1;
	    counter_hs <= 0;
	 end
	 else
	   counter_hs <= counter_hs + 1;
      end	
   end

   assign lcd_clk = (rest_n == 1) ? clk : 1'b0;
   assign lcd_pwm = (rest_n == 1) ? 1'b1 : 1'b0;
   assign lcd_de = (counter_hs >= thb && counter_hs <= th && counter_vs >= tvb  && counter_vs < tv) ? 1 : 0;
   assign xofs = (counter_hs >= thb)? counter_hs - thb: 0;
   assign yofs = (counter_vs >= tvb)? counter_vs - tvb: 0;

   reg [15:0] read_addr; 
   assign addr = read_addr;
   
   always@(posedge clk or negedge rest_n)
     begin
        if (!rest_n)
          read_addr <= 16'd0;
        else if (lcd_de) // img_ack)
          read_addr <= xofs + yofs * IMG_W;
        else
          read_addr <= 16'd0;  
     end
   
endmodule
