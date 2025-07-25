TOM PhD Summer School 2025 · Group Project (see competition details here: https://sites.google.com/view/tomsociety/tom-initiatives/nk-competition)
By Runar J. Solberg, Ali Pourentezari and Shikhar Bhardwaj

The code reproduces our competition result over 100 000 random NK-landscapes (N = 10, K = 3)=~ 0.73755

Keep only one incumbent string (the best seen so far). This is the classic (1 + 1) evolutionary strategy—a limiting case of a genetic algorithm (population = 1, variation = mutation only).
We use two mutation modes (1) Local step: flip one random bit of the incumbent or (2) long jump with probability p = 0.60 flip 7 random bits at once.
After each evaluation, if the new fitness exceeds the record, promote the string to incumbent (Greedy update).
