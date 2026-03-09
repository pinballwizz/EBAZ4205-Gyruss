---------------------------------------------------------------------------------
--                            Gyruss - EBAZ4205
--                           Code from MiSTer-X
--
--                         Modified for EBAZ4205 
--                            by pinballwiz.org 
--                               07/03/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Fire
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
--   UP arrow    : Move Up
--   DOWN arrow  : Move Down
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity gyruss_ebaz4205 is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic; -- pulled up
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	greenLED 	: out std_logic;
	redLED 	    : out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	led         : out std_logic_vector(7 downto 0)
);
end gyruss_ebaz4205;
------------------------------------------------------------------------------
architecture struct of gyruss_ebaz4205 is
 
 signal	clock_48        : std_logic;
 signal	clock_24        : std_logic;
 signal	clock_12        : std_logic;
 signal	clock_9         : std_logic;
 signal	clock_7         : std_logic;
 signal	clock_3p58      : std_logic;
 --
 signal video_r         : std_logic_vector(5 downto 0);
 signal video_g         : std_logic_vector(5 downto 0);
 signal video_b         : std_logic_vector(5 downto 0);
 --
 signal video_r_i         : std_logic_vector(5 downto 0);
 signal video_g_i         : std_logic_vector(5 downto 0);
 signal video_b_i         : std_logic_vector(5 downto 0);
 --
 signal oRGB            : std_logic_vector(7 downto 0);
 --
 signal h_sync          : std_logic;
 signal v_sync	        : std_logic;
 signal hblank          : std_logic;
 signal vblank	        : std_logic;
 signal pclk	        : std_logic;
 --
 signal hpos            : std_logic_vector(8 downto 0);
 signal vpos            : std_logic_vector(8 downto 0);
 signal pout            : std_logic_vector(7 downto 0);
 --
 signal audio_l         : std_logic_vector(15 downto 0);
 signal audio_r         : std_logic_vector(15 downto 0);
 --
 signal INP0            : std_logic_vector(7 downto 0);
 signal INP1            : std_logic_vector(7 downto 0);
 signal INP2            : std_logic_vector(7 downto 0);
 --
 signal reset           : std_logic;
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(9 downto 0);
  --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
 signal ADS             : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
component gyruss_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

reset       <= not I_RESET; -- reset active = '1'  
greenLED    <= '1'; -- turn off leds
redLED      <= '1';
---------------------------------------------------------------------------
Clocks: gyruss_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_48,
        clk_out2  => clock_9,
        clk_out3  => clock_7
    );
---------------------------------------------------------------------------
-- Clocks Divide

process (clock_48)
begin
 if rising_edge(clock_48) then
	clock_24  <= not clock_24;
 end if;
end process;
--
process (clock_24)
begin
 if rising_edge(clock_24) then
	clock_12  <= not clock_12;
 end if;
end process;
--
process (clock_7)
begin
 if rising_edge(clock_7) then
	clock_3p58  <= not clock_3p58;
 end if;
end process;
---------------------------------------------------------------------------
-- Inputs

INP0 <= "000" & not joy_BBBBFRLDU(6) & not joy_BBBBFRLDU(5) & "00" & not joy_BBBBFRLDU(7);
INP1 <= "000" & not joy_BBBBFRLDU(4) & not joy_BBBBFRLDU(1) & not joy_BBBBFRLDU(0) & not joy_BBBBFRLDU(3) & not joy_BBBBFRLDU(2);
INP2 <= "000" & not joy_BBBBFRLDU(4) & not joy_BBBBFRLDU(1) & not joy_BBBBFRLDU(0) & not joy_BBBBFRLDU(3) & not joy_BBBBFRLDU(2);
---------------------------------------------------------------------------
-- Main

pm : entity work.FPGA_GYRUSS
port map (
RESET => reset,
MCLK  => clock_48,
SCLK  => clock_3p58,
PH    => hpos,
PV    => vpos,
PCLK  => pclk,
POUT  => pout,
SND_L => audio_l,
SND_R => audio_r,
INP0  => INP0,
INP1  => INP1,
INP2  => INP2,
DSW0  => "11111111", -- coins = all off 1c-1c
DSW1  => "10111011", -- dip15 <-> dip8 on=0 off=1 10111011 | demo_sounds off = 1 | difficulty | bonus life | cabinet = 0  | lives = 11 |
DSW2  => "00000001", -- dip16 off (demo music)
AD    => AD,
ADS   => ADS
);
----------------------------------------------------------------------------
-- Sync

HVGEN : entity work.hvgen
port map(
	HPOS => hpos,
	VPOS => vpos,
	PCLK => pclk,
	iRGB => pout,
	oRGB => oRGB, -- 7 downto 0 -- b & g & r,
	HBLK => hblank,
	VBLK => vblank,
	HSYN => h_sync,
	VSYN => v_sync,
	HOFFS => "00000010",
	VOFFS => "00000000"
);
-----------------------------------------------------------------
video_r_i <= oRGB(2 downto 0) & oRGB(2 downto 0);
video_g_i <= oRGB(5 downto 3) & oRGB(5 downto 3);
video_b_i <= oRGB(7 downto 6) & oRGB(7 downto 6) & oRGB(7 downto 6);
-----------------------------------------------------------------
-- scan doubler

dblscan: entity work.scandoubler
	port map(
		clk_sys => clock_24,
		scanlines => "00",
		r_in   => video_r_i,
		g_in   => video_g_i,
		b_in   => video_b_i,
		hs_in  => h_sync,
		vs_in  => v_sync,
		r_out  => video_r,
		g_out  => video_g,
		b_out  => video_b,
		hs_out => O_HSYNC,
		vs_out => O_VSYNC
	);
-----------------------------------------------------------------------------
-- vga output

 O_VIDEO_R  <= video_r(5 downto 3);
 O_VIDEO_G  <= video_g(5 downto 3);
 O_VIDEO_B  <= video_b(5 downto 4);
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk           => clock_9,
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- dacs

    dacl : entity work.dac
    generic map(
      msbi_g  => 15
    )
    port  map(
      clk_i   => clock_12,
      res_n_i => '1',
      dac_i   => audio_l,
      dac_o   => O_AUDIO_L
    );
--
    dacr : entity work.dac
    generic map(
      msbi_g  => 15
    )
    port  map(
      clk_i   => clock_12,
      res_n_i => '1',
      dac_i   => audio_r,
      dac_o   => O_AUDIO_R
    );

-------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(11 downto 4); -- main cpu
     --   led(7 downto 0) <= not ADS(11 downto 4); -- snd cpu
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;	
-------------------------------------------------------------------------------
end struct;