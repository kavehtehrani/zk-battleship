use dep::zk_battleship_common::{Ship, Config, expand_cells, in_bounds, commit_board, has_overlap, MAX_SHIPS, MAX_CELLS};

fn check_ship_bounds(ship: Ship, cfg: Config) -> Field {
	let mut ok = 1;
	ok = ok & in_bounds(ship.x, ship.y, cfg.width, cfg.height);
	let len = ship.len;
	if len == 0 { return ok; }
	for j in 0..MAX_CELLS {
		if j == len { break; }
		let dx = (ship.dir == 0) * j;
		let dy = (ship.dir == 1) * j;
		let cx = ship.x + dx;
		let cy = ship.y + dy;
		ok = ok & in_bounds(cx, cy, cfg.width, cfg.height);
	}
	ok
}

fn main(commitment: pub Field, ships: [Ship; MAX_SHIPS], cfg: Config) {
	let mut counted = 0;
	for i in 0..MAX_SHIPS {
		counted += (ships[i].len != 0);
	}
	constrain counted == cfg.fleet_count;

	for i in 0..MAX_SHIPS {
		constrain ships[i].len == cfg.fleet_lens[i];
	}

	let mut all_ok = 1;
	for i in 0..MAX_SHIPS {
		all_ok = all_ok & check_ship_bounds(ships[i], cfg);
	}
	constrain all_ok == 1;

	let cells = expand_cells(ships, cfg);
	let overlap = has_overlap(cells);
	constrain overlap == 0;

	let c = commit_board(cells, cfg);
	constrain c == commitment;
}


