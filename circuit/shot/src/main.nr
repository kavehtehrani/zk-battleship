use dep::zk_battleship_common::{Ship, Config, expand_cells, commit_board, in_bounds, cell_index, is_hit, MAX_SHIPS};

fn main(commitment: pub Field,
        shot_x: pub Field,
        shot_y: pub Field,
        hit: pub Field,
        ships: [Ship; MAX_SHIPS],
        cfg: Config) {
	let cells = expand_cells(ships, cfg);
	let c = commit_board(cells, cfg);
	constrain c == commitment;

	let ok = in_bounds(shot_x, shot_y, cfg.width, cfg.height);
	constrain ok == 1;

	let shot_idx = cell_index(shot_x, shot_y, cfg.width);
	let computed = is_hit(cells, shot_idx);
	constrain computed == hit;
}


