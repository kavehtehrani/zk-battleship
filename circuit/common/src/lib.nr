// Compile-time limits
pub comptime MAX_SHIPS: u32 = 10;
pub comptime MAX_CELLS: u32 = 200;

use dep::std::hash::poseidon;

pub struct Ship {
	pub x: Field,
	pub y: Field,
	pub dir: Field, // 0 = horizontal, 1 = vertical
	pub len: Field,
}

pub struct Config {
	pub width: Field,
	pub height: Field,
	pub fleet_count: Field,
	pub fleet_lens: [Field; MAX_SHIPS],
	pub game_id: Field,
	pub salt: Field,
}

pub fn in_bounds(x: Field, y: Field, width: Field, height: Field) -> Field {
	let x_ok = (x >= 0) & (x < width);
	let y_ok = (y >= 0) & (y < height);
	x_ok & y_ok
}

pub fn cell_index(x: Field, y: Field, width: Field) -> Field {
	y * width + x
}

pub fn expand_cells(ships: [Ship; MAX_SHIPS], cfg: Config) -> [Field; MAX_CELLS] {
	let mut out: [Field; MAX_CELLS] = [0; MAX_CELLS];
	let mut cursor = 0;

	for i in 0..MAX_SHIPS {
		let len = ships[i].len;
		if len == 0 { continue; }
		for j in 0..MAX_CELLS {
			if j == len { break; }
			let dx = (ships[i].dir == 0) * j;
			let dy = (ships[i].dir == 1) * j;
			let cx = ships[i].x + dx;
			let cy = ships[i].y + dy;
			let idx = cell_index(cx, cy, cfg.width);
			out[cursor] = idx;
			cursor += 1;
		}
	}
	for k in cursor..MAX_CELLS {
		out[k] = -1;
	}
	out
}

pub fn commit_board(cells: [Field; MAX_CELLS], cfg: Config) -> Field {
	let mut acc = 0;
	for i in 0..MAX_CELLS {
		acc = poseidon([acc, cells[i]]);
	}
	acc = poseidon([acc, cfg.width, cfg.height, cfg.fleet_count]);
	for i in 0..MAX_SHIPS {
		acc = poseidon([acc, cfg.fleet_lens[i]]);
	}
	acc = poseidon([acc, cfg.game_id, cfg.salt]);
	acc
}

pub fn has_overlap(cells: [Field; MAX_CELLS]) -> Field {
	let mut overlap = 0;
	for i in 0..MAX_CELLS {
		if cells[i] == -1 { continue; }
		for j in (i + 1)..MAX_CELLS {
			if cells[j] == -1 { continue; }
			if cells[i] == cells[j] {
				overlap = 1;
			}
		}
	}
	overlap
}

pub fn is_hit(cells: [Field; MAX_CELLS], shot_idx: Field) -> Field {
	let mut hit = 0;
	for i in 0..MAX_CELLS {
		if cells[i] == -1 { continue; }
		if cells[i] == shot_idx {
			hit = 1;
		}
	}
	hit
}


