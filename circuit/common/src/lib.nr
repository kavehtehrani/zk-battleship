// Global constants for array sizes
pub global MAX_SHIPS: u32 = 10;
pub global MAX_CELLS: u32 = 200;

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

// Check if coordinates are within bounds
pub fn in_bounds(x: Field, y: Field, width: Field, height: Field) -> Field {
	// Check that width > x and height > y
	let width_diff = width - x;
	let height_diff = height - y;
	let width_ok = if width_diff != 0 { 1 } else { 0 };
	let height_ok = if height_diff != 0 { 1 } else { 0 };
	// Combine checks: both must be 1
	let both_ok = width_ok * height_ok;
	both_ok
}

pub fn cell_index(x: Field, y: Field, width: Field) -> Field {
	y * width + x
}

pub fn expand_cells(ships: [Ship; MAX_SHIPS], cfg: Config) -> [Field; MAX_CELLS] {
	let mut out: [Field; MAX_CELLS] = [0; MAX_CELLS];
	let mut cursor = 0;

	for i in 0..MAX_SHIPS {
		let len = ships[i].len;
		let len_is_zero = if len == 0 { 1 } else { 0 };
		if len_is_zero == 0 {
			let len_u32 = len as u32;
			for j in 0..MAX_CELLS {
				let j_u32 = j;
				let should_use = if j_u32 < len_u32 { 1 } else { 0 };
				if should_use == 1 {
					let dir_is_horiz = if ships[i].dir == 0 { 1 } else { 0 };
					let dir_is_vert = if ships[i].dir == 1 { 1 } else { 0 };
					let j_field = j as Field;
					let dx = dir_is_horiz * j_field;
					let dy = dir_is_vert * j_field;
					let cx = ships[i].x + dx;
					let cy = ships[i].y + dy;
					let idx = cell_index(cx, cy, cfg.width);
					let cursor_u32 = cursor as u32;
					if cursor_u32 < MAX_CELLS {
						out[cursor] = idx;
						cursor += 1;
					}
				}
			}
		}
	}
	// Fill remaining slots with -1
	for k in 0..MAX_CELLS {
		let k_u32 = k;
		let cursor_u32 = cursor as u32;
		let should_fill = if k_u32 >= cursor_u32 { 1 } else { 0 };
		if should_fill == 1 {
			out[k] = -1;
		}
	}
	out
}

use poseidon::poseidon2::Poseidon2;

pub fn commit_board(cells: [Field; MAX_CELLS], cfg: Config) -> Field {
	// Build the input array: cells + config fields + fleet_lens + game_id + salt
	// Total size: MAX_CELLS + 3 + MAX_SHIPS + 2 = MAX_CELLS + MAX_SHIPS + 5
	let mut input: [Field; MAX_CELLS + MAX_SHIPS + 5] = [0; MAX_CELLS + MAX_SHIPS + 5];
	let mut idx = 0;
	
	// Add all cells
	for i in 0..MAX_CELLS {
		input[idx] = cells[i];
		idx += 1;
	}
	
	// Add config dimensions and fleet count
	input[idx] = cfg.width;
	idx += 1;
	input[idx] = cfg.height;
	idx += 1;
	input[idx] = cfg.fleet_count;
	idx += 1;
	
	// Add fleet lengths
	for i in 0..MAX_SHIPS {
		input[idx] = cfg.fleet_lens[i];
		idx += 1;
	}
	
	// Add game_id and salt
	input[idx] = cfg.game_id;
	idx += 1;
	input[idx] = cfg.salt;
	
	// Hash with message_size = idx (actual length used)
	Poseidon2::hash(input, idx as u32)
}

pub fn has_overlap(cells: [Field; MAX_CELLS]) -> Field {
	let mut overlap = 0;
	for i in 0..MAX_CELLS {
		let cell_i_empty = if cells[i] == -1 { 1 } else { 0 };
		if cell_i_empty == 0 {
			for j in (i + 1)..MAX_CELLS {
				let cell_j_empty = if cells[j] == -1 { 1 } else { 0 };
				if cell_j_empty == 0 {
					let cells_match = if cells[i] == cells[j] { 1 } else { 0 };
					if cells_match == 1 {
						overlap = 1;
					}
				}
			}
		}
	}
	overlap
}

pub fn is_hit(cells: [Field; MAX_CELLS], shot_idx: Field) -> Field {
	let mut hit = 0;
	for i in 0..MAX_CELLS {
		let cell_empty = if cells[i] == -1 { 1 } else { 0 };
		if cell_empty == 0 {
			let matches = if cells[i] == shot_idx { 1 } else { 0 };
			if matches == 1 {
				hit = 1;
			}
		}
	}
	hit
}
