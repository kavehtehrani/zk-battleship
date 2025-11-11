use dep::zk_battleship_common::{Ship, Config, expand_cells, in_bounds, commit_board, has_overlap, MAX_SHIPS, MAX_CELLS};

fn check_ship_bounds(ship: Ship, cfg: Config) -> Field {
	let mut ok = 1;
	let base_ok = in_bounds(ship.x, ship.y, cfg.width, cfg.height);
	ok = ok * base_ok; // Both must be 1
	let len = ship.len;
	let len_is_zero = if len == 0 { 1 } else { 0 };
	if len_is_zero == 0 {
		let len_u32 = len as u32;
		for j in 0..MAX_CELLS {
			let j_u32 = j;
			let should_process = if j_u32 < len_u32 { 1 } else { 0 };
			if should_process == 1 {
				let dir_is_horiz = if ship.dir == 0 { 1 } else { 0 };
				let dir_is_vert = if ship.dir == 1 { 1 } else { 0 };
				let j_field = j as Field;
				let dx = dir_is_horiz * j_field;
				let dy = dir_is_vert * j_field;
				let cx = ship.x + dx;
				let cy = ship.y + dy;
				let cell_ok = in_bounds(cx, cy, cfg.width, cfg.height);
				ok = ok * cell_ok; // Both must be 1
			}
		}
	}
	ok
}

fn main(commitment: pub Field, ships: [Ship; MAX_SHIPS], cfg: Config) {
	let mut counted = 0;
	for i in 0..MAX_SHIPS {
		let len_nonzero = if ships[i].len != 0 { 1 } else { 0 };
		counted += len_nonzero;
	}
	assert(counted == cfg.fleet_count);

	for i in 0..MAX_SHIPS {
		assert(ships[i].len == cfg.fleet_lens[i]);
	}

	let mut all_ok = 1;
	for i in 0..MAX_SHIPS {
		let ship_ok = check_ship_bounds(ships[i], cfg);
		all_ok = all_ok * ship_ok; // All must be 1
	}
	assert(all_ok == 1);

	let cells = expand_cells(ships, cfg);
	let overlap = has_overlap(cells);
	assert(overlap == 0);

	let c = commit_board(cells, cfg);
	assert(c == commitment);
}
