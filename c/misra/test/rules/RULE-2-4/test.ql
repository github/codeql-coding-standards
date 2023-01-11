import cpp

// from UserType ut
// where ut.isAffectedByMacro()
// select ut
select any(Location l).toString() as s, count(Location l | l.toString() = s)
