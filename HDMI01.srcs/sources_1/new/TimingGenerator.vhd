----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2026 11:04:15 AM
-- Design Name: 
-- Module Name: TimingGenerator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TimingGenerator is
generic (
    -- Horizontal Timing
        H_ACTIVE      : integer := 1280;   -- Active pixels
        H_FRONT_PORCH : integer := 110;
        H_SYNC_WIDTH  : integer := 40;
        H_BACK_PORCH  : integer := 220;

    -- Vertical Timing
        V_ACTIVE      : integer := 720;    -- Active lines
        V_FRONT_PORCH : integer := 5;
        V_SYNC_WIDTH  : integer := 5;
        V_BACK_PORCH  : integer := 20;

    -- Polarities (0 = active low, 1 = active high)
        H_SYNC_POLARITY : std_logic := '1';  -- for 720p usually positive
        V_SYNC_POLARITY : std_logic := '1'
);
Port ( 
-- input ports 
    PxlCLk  : in std_logic ; --74.25 MHz for 720p 
    nRst    : in std_logic ; 
    
-- output ports 
    vSync   : out std_logic ; 
    hSync   : out std_logic ; 
    de      :  out std_logic ; 
    x       :  out integer range 0 to H_ACTIVE-1 ;
    y       :  out integer range 0 to V_ACTIVE-1  
    
    );
end TimingGenerator;

architecture Behavioral of TimingGenerator is
-- Total Horizontal and Vertical Count Decleration 
    constant H_TOTAL : integer := H_ACTIVE + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH ;
    constant V_TOTAL : integer := V_ACTIVE + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH ;
    
-- Signal for horizontal and vertical counting 
    signal h_count : integer range 0 to H_TOTAL-1 ;  
    signal v_count : integer range 0 to V_TOTAL-1 ;

begin

CountPrcss : process(PxlCLk,nRst) 
begin 
    if (rising_edge(PxlCLk)) then 
        if (nRst = '0') then 
            h_count <= 0 ; 
            v_count <= 0 ; 
        else 
-----------------------------------------------------------------        
            --horizontal Count 
            if (h_count = H_TOTAL-1) then
                h_count <= 0 ; 
                if((v_count = V_TOTAL-1)) then 
                    v_count <= 0 ;
                else 
                    v_count <= v_count + 1 ; 
                end if ;   
            else                  
                h_count <= h_count + 1; 
            end if ;
            

---------------------------------------------------------------


        end if ;
    end if ;  
    
end process ; 

-- hsync generation
hsync <= H_SYNC_POLARITY when (h_count >= H_ACTIVE + H_FRONT_PORCH + H_BACK_PORCH ) and 
                              (h_count <  H_ACTIVE + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH ) 
             else not H_SYNC_POLARITY;

    -- VSYNC generation
vsync <= V_SYNC_POLARITY when (v_count >= V_ACTIVE + V_FRONT_PORCH + V_BACK_PORCH ) and 
                              (v_count <  V_ACTIVE + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH )
              else '0';

de <= '1' when (h_count < H_ACTIVE + H_BACK_PORCH) and (h_count > H_BACK_PORCH) 
           and (v_count < V_ACTIVE + V_BACK_PORCH) and (v_count > V_BACK_PORCH) 
           else not H_SYNC_POLARITY ;
           
x <= h_count when (h_count < H_ACTIVE) else 0;
y <= v_count when v_count < V_ACTIVE else 0; 


---- AI Generated 
---- HSYNC generation
--    hsync <= H_SYNC_POLARITY when (h_count >= H_ACTIVE + H_FRONT_PORCH) and 
--                                 (h_count <  H_ACTIVE + H_FRONT_PORCH + H_SYNC_WIDTH) 
--             else not H_SYNC_POLARITY;

--    -- VSYNC generation
--    vsync <= V_SYNC_POLARITY when (v_count >= V_ACTIVE + V_FRONT_PORCH) and 
--                                 (v_count <  V_ACTIVE + V_FRONT_PORCH + V_SYNC_WIDTH) 
--             else not V_SYNC_POLARITY;

--    -- Data Enable
--    de <= '1' when (h_count < H_ACTIVE) and (v_count < V_ACTIVE) else '0';

--    -- Pixel coordinates (only valid when de = '1')
--    x <= h_count when h_count < H_ACTIVE else 0;
--    y <= v_count when v_count < V_ACTIVE else 0;


end Behavioral;
