----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2026 01:17:42 PM
-- Design Name: 
-- Module Name: TMDS_Encdr - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TMDS_Encdr is
generic (
    DATA_WIDTH : integer := 8 
);
Port (
--input ports 
    PxlClk : in std_logic ; 
    nRst : in std_logic ; 
    Data : in std_logic_vector (DATA_WIDTH-1 downto 0); 
    c0 : in std_logic ; 
    c1 : in std_logic ; 
    de : in std_logic ;
--output ports     
    Q_out : out std_logic_vector (9 downto 0)
    
 );
end TMDS_Encdr;

architecture Behv of TMDS_Encdr is

    signal q_m : std_logic_vector(8 downto 0) := (others => '0'); -- 9 middle bits 
    signal disparity : signed (4 downto 0) := (others => '0') ; -- DC Balancing
    signal ctrlBit : std_logic_vector (1 downto 0) ; 
--    signal n1_data   : integer;
--    signal q_m_temp  : std_logic_vector(8 downto 0);
    signal q_out_temp: std_logic_vector(9 downto 0);
    signal new_disp  : signed(4 downto 0) := (others => '0');
    signal Data_reg  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal de_reg    : std_logic;
    
    --function to count ones 
    function count_ones(v : std_logic_vector) return integer is 
        variable cnt : integer := 0 ;
    begin
        for i in v'range loop 
            if (v(i) = '1') then 
                cnt := cnt + 1 ; 
            end if ;
        end loop ; 
        return cnt ;
    end function ; 

begin

----------------------------------------
-- register the input data and de signal (pipeline stage 1)
----------------------------------------
    process(PxlClk , nRst) 

    begin 
        if (rising_edge(PxlClk)) then 
            if (nRst = '0') then
                de_reg <= '0';
                Data_reg <= (others => '0');
                ctrlBit <= "00";
                disparity <= (others => '0');
                Q_out <= q_out_temp ; 
            else 
                Data_reg <= Data;
                de_reg <= de;
                disparity <= new_disp;
                ctrlBit <= (c1 & c0);
                Q_out <= q_out_temp ; 
            end if ;
        end if ;
    end process ;

------------------------------------------
---- stage 1 : decision making for XOR or XNOR
------------------------------------------
    assert DATA_WIDTH = 8 report "DATA_WIDTH must be 8" severity failure;
    
process(Data_reg , nRst) 
    variable n1_data : integer;
    variable q_m_temp : std_logic_vector(8 downto 0);
begin 
    if (nRst = '1') then 
        n1_data := count_ones(Data_reg);
    
        if ((n1_data > 4) or ((n1_data = 4) and (Data_reg(0) = '0'))) then 
            -- XNOR        
            q_m_temp(0) := Data_reg(0); 
            for i in 1 to DATA_WIDTH-1 loop 
                q_m_temp(i) := Data_reg(i) xnor q_m_temp(i-1);
            end loop ;
            q_m_temp(8) := '0';
        else 
            -- XOR
            q_m_temp(0) := Data_reg(0); 
            for i in 1 to DATA_WIDTH-1 loop 
                q_m_temp(i) := Data_reg(i) xor q_m_temp(i-1);
            end loop ;
            q_m_temp(8) := '1';
        end if ;
    
    q_m <= q_m_temp(8 downto 0);
    else 
        q_m_temp := (others => '0');
        q_m <= (others => '0');
        n1_data := 0;
    end if ;    
end process;
----------------------------------------
-- stage 2 : DC Balancing Decision 
----------------------------------------
    process(q_m , nRst , disparity , de_reg , ctrlBit) 
    variable n1_q_m    : integer;
    begin 
    if (nRst = '1') then 
        if (de_reg = '1') then 
            n1_q_m := count_ones(q_m(7 downto 0));
            if (disparity = 0) or (n1_q_m = 4) then
                q_out_temp(9) <= not q_m(8); 
                q_out_temp(8) <= q_m(8); 
                if q_m(8) = '1' then
                    q_out_temp(7 downto 0) <= q_m(7 downto 0);
                    new_disp <= disparity + to_signed( (2 * n1_q_m) - 8 - 2*(1 - to_integer(unsigned'("" & q_m(8)))) , 5);
                else
                    q_out_temp(7 downto 0) <= not q_m(7 downto 0);  
                    new_disp <= disparity + to_signed( (8 - n1_q_m) - n1_q_m , 5) + to_signed(2 * to_integer(unsigned'("" & q_m(8))), 5);
                end if;
            else
                 
                if ( (disparity > 0) and (n1_q_m > 4) ) or    
                    ( (disparity < 0) and (n1_q_m < 4) ) then
                    q_out_temp(9) <= '1';       
                    q_out_temp(8) <= q_m(8);    
                    q_out_temp(7 downto 0) <= not q_m(7 downto 0); 
                    new_disp <= disparity + to_signed( (8 - n1_q_m) - n1_q_m , 5) + to_signed(2 * to_integer(unsigned'("" & q_m(8))), 5);
                else
                
                    q_out_temp(9) <= '0';
                    q_out_temp(8) <= q_m(8);
                    q_out_temp(7 downto 0) <= q_m(7 downto 0);
                    new_disp <= disparity + to_signed( (2 * n1_q_m) - 8 - 2*(1 - to_integer(unsigned'("" & q_m(8)))) , 5);
                end if ;
                    
            end if ; 
                --disparity <= new_disp ; 
        else 
        new_disp <= (others => '0');
        case (ctrlBit) is 
            when "00" => q_out_temp <= "1101010100";
            when "01" => q_out_temp <= "0010101011";
            when "10" => q_out_temp <= "0101010100";
            when others => q_out_temp <= "1010101011";
        end case;
        end if ;
    else 
        q_out_temp <= (others => '0');
        new_disp <= (others => '0');
    end if ;
    --Q_out <= q_out_temp;
        
    end process ;


end Behv;
