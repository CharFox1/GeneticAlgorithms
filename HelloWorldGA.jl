# a short genetic algorithm to print "Hello, World!" (or anything else)

using Random
using Printf

mutable struct Member
	genome::Array{Char}
	score::Float64
end 

mutable struct Population
	members::Array{Member}
end

function createMembers(popSize, genomeSize, characters)
	# randomize starting string for each member
	members = [deepcopy(Member(
		collect(randstring(characters, genomeSize)), 0))
		 for i in 1:popSize]
	return members
end

function scoreMember(m::Member, goal)
	# count number of characters that match goal (in correct positions too)
	m.score = sum(m.genome .== goal)
end

function mutateMember(m::Member, characters)
	genomeSize = length(m.genome)
	# randomly select a character to mutate
	charLoc = rand(1:genomeSize)
	# returns an array of one random char so just grab it
	randChar = randstring(characters, 1)[1]
	# change random char
	m.genome[charLoc] = randChar
end

function generation(cullPercent, p::Population, characters, goal)
	# remove bottom x %
	# create new members using mutation of surviving
	popSize = length(p.members)

	# sort in place
	sort!(p.members, by=m->m.score, rev=true)

	# how many members to remove
	removeNum = Int64(floor(cullPercent*popSize))

	# replace those worst members with new ones
	for i in (popSize-removeNum)+1:popSize
		# make a copy of one of the better members
		memberCopy = deepcopy(p.members[rand(1:popSize-removeNum)])
		# mutate and replace the bad one
		mutateMember(memberCopy, characters)
		# update score
		scoreMember(memberCopy, goal)
		p.members[i] = memberCopy
	end
end

function runAlg()
	# create list of all possible characters members can have
	characters = String(cat(dims=1, collect('A':'Z'), collect('a':'z'), collect('0':'9'))) * " ,.!"
	#println(characters)
	# how many characters each member can have
	genomeSize = 16
	# how many members there are in the population
	popSize = 100
	# what percent of members are removed every generation
	cullPercent = 0.95
	goal = collect("Hello, World!")
	# make goal as long as genome for easy comparison
	append!(goal, Vector{Char}(" "^(genomeSize - length(goal))))

	# create population and iterate generations until goal is found
	p = Population(createMembers(popSize, genomeSize, characters))
	i = 1
	while String(p.members[1].genome) != String(goal)
		generation(cullPercent, p, characters, goal)
		# print out the iteration and current best string nicely
		@printf "Iteration %3d:   %s\n" i String(p.members[1].genome)
		i += 1
	end
end

runAlg()