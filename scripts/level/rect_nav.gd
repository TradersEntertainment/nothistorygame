class_name RectNav
## Düz zeminde dikdörtgen engellerin (XZ düzleminde Rect2: x, z) çevresinden dolanan yürüyüş yolu. Görünürlük çizgesi:
## düğümler engel köşelerinin biraz dışı, kenarlar hiçbir engelin gövde payını kesmeyen doğru parçaları; en kısa yol
## Dijkstra ile. Sahne betiğiyle yürütülen NPC'ler (Bölüm 8'in ajanları, 39o'nun yeniçerisi ve yağmacıları) bununla
## rafların, molozun, kuyunun içinden geçmez.


## Doğru parçası a→b, dikdörtgenin içinden geçiyor mu (kenara değmek geçmek sayılmaz)
static func seg_hits(a: Vector2, b: Vector2, r: Rect2) -> bool:
	var t0 := 0.0
	var t1 := 1.0
	for ax in 2:
		var p := a[ax]
		var d := b[ax] - p
		var lo := r.position[ax]
		var hi := r.end[ax]
		if absf(d) < 0.000001:
			if p <= lo or p >= hi:
				return false
			continue
		var ta := (lo - p) / d
		var tb := (hi - p) / d
		t0 = maxf(t0, minf(ta, tb))
		t1 = minf(t1, maxf(ta, tb))
		if t0 >= t1:
			return false
	return true


## a→b yürünebilir mi: hiçbir engele r (gövde yarıçapı) kadar yaklaşmaz. Ucu zaten bir engelin payında olan (itilmiş
## kişi) oradan çıkabilsin diye o engelde yalnız engelin kendisi sayılır (pay değil).
static func clear(a: Vector2, b: Vector2, obs: Array[Rect2], r: float) -> bool:
	for o in obs:
		var g := o.grow(r)
		if g.has_point(a) or g.has_point(b):
			g = o
		if seg_hits(a, b, g):
			return false
	return true


## from'dan to'ya engellerin çevresinden dolanan yol (son nokta to; from dahil değil; yükseklik to.y). Yol yoksa düz.
static func path(from: Vector3, to: Vector3, obs: Array[Rect2], r: float) -> Array[Vector3]:
	var a := Vector2(from.x, from.z)
	var b := Vector2(to.x, to.z)
	var out: Array[Vector3] = []
	if clear(a, b, obs, r):
		out.append(to)
		return out
	var nodes: Array[Vector2] = [a, b]
	var m := r + 0.3
	for o in obs:
		var g := o.grow(m)
		for c in [g.position, Vector2(g.end.x, g.position.y), g.end, Vector2(g.position.x, g.end.y)]:
			var inside := false
			for o2 in obs:
				if o2.grow(r).has_point(c):
					inside = true
					break
			if not inside:
				nodes.append(c)
	var n := nodes.size()
	var dist: Array[float] = []
	var prev: Array[int] = []
	var done: Array[bool] = []
	for i in n:
		dist.append(INF)
		prev.append(-1)
		done.append(false)
	dist[0] = 0.0
	while true:
		var u := -1
		for i in n:
			if not done[i] and dist[i] < INF and (u < 0 or dist[i] < dist[u]):
				u = i
		if u < 0 or u == 1:
			break
		done[u] = true
		for v in n:
			if done[v] or v == u:
				continue
			var nd := dist[u] + nodes[u].distance_to(nodes[v])
			if nd < dist[v] and clear(nodes[u], nodes[v], obs, r):
				dist[v] = nd
				prev[v] = u
	if prev[1] < 0:
		out.append(to)
		return out
	var i := 1
	while i > 0:
		out.push_front(Vector3(nodes[i].x, to.y, nodes[i].y))
		i = prev[i]
	out[out.size() - 1] = to
	return out


## Bu nokta bir engelin içinde mi (r metre payla)
static func inside(p: Vector3, obs: Array[Rect2], r: float) -> bool:
	for o in obs:
		if o.grow(r).has_point(Vector2(p.x, p.z)):
			return true
	return false
