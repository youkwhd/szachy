with Player;
with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Characters.Handling;
with Interfaces.C;
with pgn_piece_h;
with pgn_coordinate_h;

package body Board is
    use Player;
    use Ada.Text_IO;
    use Ada.Integer_Text_IO;
    use Ada.Characters.Handling;
    use Interfaces.C;
    use pgn_piece_h;
    use pgn_coordinate_h;

    procedure Put_Board_Line (Board : Board_Mat) is
    begin
        for I in Board_Mat_Col loop
            Put (Integer (-(Integer (I) - BOARD_WIDTH)), Width => 0);

            for J in Board_Mat_Row loop
                Put (" ");
                Put (Board (I, J));
            end loop;
            New_Line;

        end loop;

        Put (" ");
        for I in Board_Mat_Row loop
            Put (" ");
            Put (Character'Val (Character'Pos ('a') + I));
        end loop;
        New_Line;
    end Put_Board_Line;

    function Is_Coor_Inside_Board (X, Y : Integer) return Boolean is
    begin
        return (X >= 0 and X <= BOARD_MAX_ROW) and (Y >= 0 and Y <= BOARD_MAX_COL);
    end Is_Coor_Inside_Board;

    procedure Move_Castles (Board : in out Board_Mat; P : Player_T; Player_Move : pgn_move_t) is
    begin
        case Player_Move.Castles is
            when PGN_CASTLING_KINGSIDE =>
                case P is
                    when Player_T'(White) =>
                        board(7, 4) := ' ';
                        board(7, 5) := To_Upper (Character (Pgn_Piece_To_Char (PGN_PIECE_ROOK)));
                        board(7, 6) := To_Upper (Character (Pgn_Piece_To_Char (PGN_PIECE_KING)));
                        board(7, 7) := ' ';
                    when Player_T'(Black) =>
                        board(0, 4) := ' ';
                        board(0, 5) := To_Lower (Character (Pgn_Piece_To_Char (PGN_PIECE_ROOK)));
                        board(0, 6) := To_Lower (Character (Pgn_Piece_To_Char (PGN_PIECE_KING)));
                        board(0, 7) := ' ';
                end case;
            when PGN_CASTLING_QUEENSIDE =>
                case P is
                    when Player_T'(White) =>
                        board(7, 0) := ' ';
                        board(7, 2) := To_Upper (Character (Pgn_Piece_To_Char (PGN_PIECE_KING)));
                        board(7, 3) := To_Upper (Character (Pgn_Piece_To_Char (PGN_PIECE_ROOK)));
                        board(7, 5) := ' ';
                    when Player_T'(Black) =>
                        board(0, 0) := ' ';
                        board(0, 2) := To_Lower (Character (Pgn_Piece_To_Char (PGN_PIECE_KING)));
                        board(0, 3) := To_Lower (Character (Pgn_Piece_To_Char (PGN_PIECE_ROOK)));
                        board(0, 5) := ' ';
                end case;
            when others =>
                Put_Line ("szachy: unreachable!");
        end case;
    end Move_Castles;

    function Move_Pawn_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
        Dest_X : Integer := char'Pos (Player_Move.Dest.X) - Character'Pos ('a');
        Dest_Y : Integer := -(Integer (Player_Move.Dest.Y) - BOARD_HEIGHT);
    begin
        case P is
            when Player_T'(White) =>
                if (X = Dest_X and Y - 1 = Dest_Y) then return TRUE; end if;
                if (X = Dest_X and Y - 2 = Dest_Y) then return TRUE; end if;

                if (Boolean (Player_Move.Captures)) then
                    if (X - 1 = Dest_X and Y - 1 = Dest_Y) then return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y - 1), Board_Mat_Row (X - 1))); end if;
                    if (X + 1 = Dest_X and Y - 1 = Dest_Y) then return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y - 1), Board_Mat_Row (X + 1))); end if;
                end if;

                if (Boolean (Player_Move.En_Passant) and X - 1 = Dest_X and Y - 1 = Dest_Y) then return TRUE; end if;
                if (Boolean (Player_Move.En_Passant) and X + 1 = Dest_X and Y - 1 = Dest_Y) then return TRUE; end if;
            when Player_T'(Black) =>
                if (X = Dest_X and y + 1 = Dest_Y) then return TRUE; end if;
                if (X = Dest_X and y + 2 = Dest_Y) then return TRUE; end if;

                if (Boolean (Player_Move.Captures)) then
                    if (X - 1 = Dest_X and Y + 1 = Dest_Y) then return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y + 1), Board_Mat_Row (X - 1))); end if;
                    if (X + 1 = Dest_X and Y + 1 = Dest_Y) then return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y + 1), Board_Mat_Row (X + 1))); end if;
                end if;

                if (Boolean (Player_Move.En_Passant) and X - 1 = Dest_X and Y + 1 = Dest_Y) then return TRUE; end if;
                if (Boolean (Player_Move.En_Passant) and X + 1 = Dest_X and Y + 1 = Dest_Y) then return TRUE; end if;
        end case;
        return FALSE;
    end Move_Pawn_Possible;

    function Move_Knight_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
        Dest_X : Integer := char'Pos (Player_Move.Dest.X) - Character'Pos ('a');
        Dest_Y : Integer := -(Integer (Player_Move.Dest.Y) - BOARD_HEIGHT);
    begin
        if (Is_Coor_Inside_Board(X - 1, Y + 2) and (X - 1 = Dest_X and Y + 2 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y + 2), Board_Mat_Row (X - 1)));
        end if;
        if (Is_Coor_Inside_Board(X + 1, Y + 2) and (X + 1 = Dest_X and Y + 2 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y + 2), Board_Mat_Row (X + 1)));
        end if;

        if (Is_Coor_Inside_Board(X - 2, Y + 1) and (X - 2 = Dest_X and Y + 1 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y + 1), Board_Mat_Row (X - 2)));
        end if;
        if (Is_Coor_Inside_Board(X + 2, Y + 1) and (X + 2 = Dest_X and Y + 1 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y + 1), Board_Mat_Row (X + 2)));
        end if;

        if (Is_Coor_Inside_Board(X - 1, Y - 2) and (X - 1 = Dest_X and Y - 2 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y - 2), Board_Mat_Row (X - 1)));
        end if;
        if (Is_Coor_Inside_Board(X + 1, Y - 2) and (X + 1 = Dest_X and Y - 2 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y - 2), Board_Mat_Row (X + 1)));
        end if;

        if (Is_Coor_Inside_Board(X - 2, Y - 1) and (X - 2 = Dest_X and Y - 1 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y - 1), Board_Mat_Row (X - 2)));
        end if;
        if (Is_Coor_Inside_Board(X + 2, Y - 1) and (X + 2 = Dest_X and Y - 1 = Dest_Y)) then
            return not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y - 1), Board_Mat_Row (X + 2)));
        end if;
        return FALSE;
    end Move_Knight_Possible;

    function Move_Bishop_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
        Dest_X : Integer := char'Pos (Player_Move.Dest.X) - Character'Pos ('a');
        Dest_Y : Integer := -(Integer (Player_Move.Dest.Y) - BOARD_HEIGHT);
    begin
        for I in 1 .. BOARD_MAX_COL loop
            if (X + I = Dest_X and Y + I = Dest_Y) then return Is_Coor_Inside_Board(X + I, Y + I); end if;
            if (X + I = Dest_X and Y - I = Dest_Y) then return Is_Coor_Inside_Board(X + I, Y - I); end if;
            if (X - I = Dest_X and Y - I = Dest_Y) then return Is_Coor_Inside_Board(X - I, Y - I); end if;
            if (X - I = Dest_X and Y + I = Dest_Y) then return Is_Coor_Inside_Board(X - I, Y + I); end if;
        end loop;
        return FALSE;
    end Move_Bishop_Possible;

    function Move_Rook_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
        Dest_X : Integer := char'Pos (Player_Move.Dest.X) - Character'Pos ('a');
        Dest_Y : Integer := -(Integer (Player_Move.Dest.Y) - BOARD_HEIGHT);
    begin
        for I in X + 1 .. BOARD_MAX_COL loop
            exit when Board(Board_Mat_Col (Y), Board_Mat_Row (I)) /= ' ' and Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y), Board_Mat_Row (I)));
            exit when Board(Board_Mat_Col (Y), Board_Mat_Row (I)) /= ' ' and not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y), Board_Mat_Row (I))) and not (I = Dest_X and Y = Dest_Y);
            if (I = Dest_X and Y = Dest_Y) then return Is_Coor_Inside_Board(I, Y); end if;
        end loop;

        for I in reverse 0 .. X - 1 loop
            exit when Board(Board_Mat_Col (Y), Board_Mat_Row (I)) /= ' ' and Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y), Board_Mat_Row (I)));
            exit when Board(Board_Mat_Col (Y), Board_Mat_Row (I)) /= ' ' and not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (Y), Board_Mat_Row (I))) and not (I = Dest_X and Y = Dest_Y);
            if (I = Dest_X and Y = Dest_Y) then return Is_Coor_Inside_Board(I, Y); end if;
        end loop;

        for I in Y + 1 .. BOARD_MAX_COL loop
            exit when Board(Board_Mat_Col (I), Board_Mat_Row (X)) /= ' ' and Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (I), Board_Mat_Row (X)));
            exit when Board(Board_Mat_Col (I), Board_Mat_Row (X)) /= ' ' and not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (I), Board_Mat_Row (X))) and not (X = Dest_X and I = Dest_Y);
            if (X = Dest_X and I = Dest_Y) then return Is_Coor_Inside_Board(X, I); end if;
        end loop;

        for I in reverse 0 .. Y - 1 loop
            exit when Board(Board_Mat_Col (I), Board_Mat_Row (X)) /= ' ' and Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (I), Board_Mat_Row (X)));
            exit when Board(Board_Mat_Col (I), Board_Mat_Row (X)) /= ' ' and not Is_Piece_Eq_To_Player(P, Board(Board_Mat_Col (I), Board_Mat_Row (X))) and not (X = Dest_X and I = Dest_Y);
            if (X = Dest_X and I = Dest_Y) then return Is_Coor_Inside_Board(X, I); end if;
        end loop;

        return FALSE;
    end Move_Rook_Possible;

    function Move_King_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
        Dest_X : Integer := char'Pos (Player_Move.Dest.X) - Character'Pos ('a');
        Dest_Y : Integer := -(Integer (Player_Move.Dest.Y) - BOARD_HEIGHT);
    begin
        for I in 0 .. 3 - 1 loop
            if (X - 1 + I = Dest_X and Y + 1 = Dest_Y) then return Is_Coor_Inside_Board(X - 1 + I, Y + 1); end if;
            if (X - 1 + I = Dest_X and Y - 1 = Dest_Y) then return Is_Coor_Inside_Board(X - 1 + I, Y - 1); end if;
        end loop;

        if (X - 1 = Dest_X and Y = Dest_Y) then return Is_Coor_Inside_Board(X - 1, Y); end if;
        if (X + 1 = Dest_X and Y = Dest_Y) then return Is_Coor_Inside_Board(X + 1, Y); end if;

        return FALSE;
    end Move_King_Possible;

    function Move_Queen_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
    begin
        return Move_King_Possible (Board, P, X, Y, Player_Move) or Move_Rook_Possible (Board, P, X, Y, Player_Move) or Move_Bishop_Possible (Board, P, X, Y, Player_Move);
    end Move_Queen_Possible;

    function Move_Is_Possible (Board : in out Board_Mat; P : Player_T; X, Y : Integer; Player_Move : pgn_move_t) return Boolean is
    begin
        case Player_Move.Piece is
            when PGN_PIECE_PAWN =>
                return Move_Pawn_Possible (Board, P, X, Y, Player_Move);
            when PGN_PIECE_KNIGHT =>
                return Move_Knight_Possible (Board, P, X, Y, Player_Move);
            when PGN_PIECE_BISHOP =>
                return Move_Bishop_Possible (Board, P, X, Y, Player_Move);
            when PGN_PIECE_ROOK =>
                return Move_Rook_Possible (Board, P, X, Y, Player_Move);
            when PGN_PIECE_QUEEN =>
                return Move_Queen_Possible (Board, P, X, Y, Player_Move);
            when PGN_PIECE_KING =>
                return Move_King_Possible (Board, P, X, Y, Player_Move);
            when others =>
                return FALSE;
        end case;
    end Move_Is_Possible;

    procedure Move (Board : in out Board_Mat; P : Player_T; Player_Move : pgn_move_t) is
        X : Integer;
        Y : Integer;
    begin
        if (Player_Move.Castles /= 0) then
            Move_Castles (Board, P, Player_Move);
            return;
        end if;

        for I in Board_Mat_Col loop
            for J in Board_Mat_Row loop
                if (To_Upper (Board(I, J)) = Character (Pgn_Piece_To_Char (Player_Move.Piece)) and Is_Piece_Eq_To_Player (P, Board(I, J))) then
                    X := Integer (J);
                    Y := Integer (I);
                    
		    -- What the fuck?
                    if ((Player_Move.From.Y /= PGN_COORDINATE_UNKNOWN and Y /= -(Integer (Player_Move.From.Y) - BOARD_HEIGHT)) or
                        (char'Pos (Player_Move.From.X) /= PGN_COORDINATE_UNKNOWN and X /= char'Pos (Player_Move.From.X) - Character'Pos ('a'))) then
                        null;
                    elsif (Move_Is_Possible (Board, P, X, Y, Player_Move)) then
                        Board(Board_Mat_Col (-(Integer (Player_Move.Dest.Y) - BOARD_WIDTH)), char'Pos (Player_Move.Dest.X) - Character'Pos ('a')) := Board(I, J);
                        Board(I, J) := ' ';

                        if (Player_Move.En_Passant) then
                            Board(Board_Mat_Col (-(Integer (Player_Move.Dest.Y) - BOARD_WIDTH) + (if P = Player_T'(White) then 1 else -1)), char'Pos (Player_Move.Dest.X) - Character'Pos ('a') + 1) := ' ';
                        end if;

                        return;
                    end if;
                end if;
            end loop;
        end loop;
    end Move;

end Board;
