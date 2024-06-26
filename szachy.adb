with pgn_h; use pgn_h;
with pgn_table_h; use pgn_table_h;
with pgn_moves_h; use pgn_moves_h;
with pgn_util_h; use pgn_util_h;

with Ansi; use Ansi;
with Player; use Player;
with Banner; use Banner;
with Board; use Board;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings; use Interfaces.C.Strings;

procedure Szachy is
    Pgn : access pgn_t;
    Pgn_Move : access uu_pgn_moves_item_t;
    Line : String := "";
begin
    Pgn := Pgn_Init;
    Pgn_Parse (Pgn, New_String ("[White ""Fischer, Robert J.""]" & LF & "[Black ""Spassky, Boris V.""]" & LF & "1. e4 e5 2. Nf3 Nc6 3. Bb5 3... a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6 1/2-1/2"));

    Put_Banner;

    Put_Line ("Simulating chess game played by:");
    Put_Line (Value (Pgn_Table_Get (Pgn.Metadata, New_String ("White"))) & " (White) against " & Value (Pgn_Table_Get (Pgn.Metadata, New_String ("Black"))) & " (Black)");
    New_Line;

    for I in 0 .. Pgn.Moves.Length - 1 loop
        Pgn_Move := Moves_Access_Nth (Pgn.Moves, I);

        Put_Line ("                    ");
        Move_Up (1);

        Put_Line ("White's Move: " & Interfaces.C.To_Ada (Pgn_Move.White.Notation));
        Move (Chess_Board, Player_T'(White), Pgn_Move.White);
        Put_Board_Line (Chess_Board);
        Line := Get_Line;
        Move_Up (BOARD_HEIGHT + 3);

        Put_Line ("                    ");
        Move_Up (1);

        Put_Line ("Black's Move: " & Interfaces.C.To_Ada (Pgn_Move.Black.Notation));
        Move (Chess_Board, Player_T'(Black), Pgn_Move.Black);
        Put_Board_Line (Chess_Board);
        Line := Get_Line;
        if (I + 1 < Pgn.Moves.Length) then Move_Up (BOARD_HEIGHT + 3); end if;
    end loop;

    Put_Line ("Score:" & unsigned_short'Image (Pgn.Score.White) & " (White)" & unsigned_short'Image (Pgn.Score.Black) & " (Black)");
    Pgn_Cleanup (Pgn);
end Szachy;

