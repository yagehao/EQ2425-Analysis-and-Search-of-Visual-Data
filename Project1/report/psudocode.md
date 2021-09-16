```pseudocode
DEFINE threshold
FOR point x in reference image:
	FOR point y in test image:
		compute d(x,y)
		IF d(x,y) < threshold:
			match x,y
```

```pseudocode
FOR point x in reference image:
	For point y in test image:
		compute d(x,y)
	get minimum d(x,y)
	match x,y
```

```pseudocode
DEFINE threshold
FOR point x in reference image:
	For point y in test image:
		compute d(x,y)
	get distance_ratio
	IF distance_ratio < threshold:
		match x,y
```



