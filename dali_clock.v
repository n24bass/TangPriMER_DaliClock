module dali_clock
  (
   // input
   input wire        CLK_IN, // 24.0MHz
   input wire        RST_N,  // reset
   // LCD 
   output wire [0:7] R,
   output wire [0:7] G,
   output wire [0:7] B,
   output wire       LCD_CLK,
   output wire       LCD_DEN,
   output wire       LCD_PWM  // backlight,set to high
   );

   wire         clk_lcd;     // 33.3MHz
   wire         clklock;

   //
   
   ip_pll pll
     (
      .refclk   (CLK_IN),  // 24.0MHz
      .reset    (~RST_N),
      .extlock  (clklock), // 33.3MHz
      .clk0_out (clk_lcd)
      );

   
   //lcd display
   wire [10:0]       X;
   wire [10:0]       Y;
   wire              lcd_rden;
   wire [15:0]       lcd_rdaddr;
   
   lcd_sync 
     #(
       .IMG_W(800),
       .IMG_H(480)
       )
   u_lcd_sync
     (
      // input
      .clk      (clk_lcd),
      .rest_n   (RST_N),
      // output
      .lcd_clk  (LCD_CLK),
      .lcd_pwm  (LCD_PWM),
      .lcd_de   (LCD_DEN),
      .xofs     (X),
      .yofs     (Y),
      .addr     (lcd_rdaddr)
      );

   data_out datout
     (
      // input
      .clk_lcd  (clk_lcd), // 33.3MHz
      // out
      .R                (R),
      .G                (G),
      .B                (B),
      // input
      .den              (LCD_DEN),
      .X                (X),
      .Y                (Y)
      );
              
endmodule
