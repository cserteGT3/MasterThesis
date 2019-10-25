using StaticArrays
using AbstractTrees
using LinearAlgebra

using Revise
using CSGBuilding
const CSGB = CSGBuilding
cd(@__DIR__)

poins2 = [[0,0], [0,1], [1,0], [1,1]]
c = CSGB.centroid(poins2)

poins3 = [[0,0,0], [0,0,1], [0,1,0], [0,1,1]]
c = CSGB.centroid(poins3)

poins33 = [SVector(i, j, k) for i in 0:1 for j in 0:1 for k in 0:1]
c = centroid(poins33)
CSGB.normedcovmat(poins33)
