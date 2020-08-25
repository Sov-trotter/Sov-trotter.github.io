@def title = "Proposal"


### गुरुर्ब्रह्मा ग्रुरुर्विष्णुः गुरुर्देवो महेश्वरः । 
### गुरुः साक्षात् परं ब्रह्म तस्मै श्री गुरवे नमः ॥ 

Guru is ~~~<ins>Brahmā</ins>~~~(the creator of universe), Guru is ~~~<ins>Vishnu</ins>~~~(the protector of universe),~~~<br>~~~ Guru is ~~~<ins>Shiv</ins>~~~(the destroyer of universe, infact Guru is ~~~<ins>Parbrahma</ins>~~~(the source of energy), 
~~~<br>~~~and I bow to him, ~~~<ins>The Sadhguru</ins>~~~(The Ultimate Pious Spiritual Guide)


As a शिष्य(student) I can't be thankful  enough to my गुरु(mentor) ~~~<a href="https://github.com/visr/">Martijn Visser</a>~~~ who mentored me on this project and for all the learning that I've done under him.    

## April-Early May
Packages like ~~~<a href="https://github.com/JuliaGeo/Shapefile.jl">Shapefile</a>~~~/~~~<a href="https://github.com/JuliaGeo/GeoJSON.jl">GeoJSON</a>~~~/~~~<a href="https://github.com/yeesian/ArchGDAL.jl">ArchGDAL</a>~~~ are main parsers for geospatial data into Julia. There has been a lot of discussion on having a tabular representation for geospatial data. R has `sf` and Python has `GeoPandas`. In Julia there has been interest in similar functionality for quite sometime now. Thanks to the ~~~<a href="https://github.com/JuliaData/Tables.jl">Tables</a>~~~ interface in Shapefile, GeoJSONTables and ArchGDAL we are getting closer.

## Motivation 
This image of R's sf `credits: Allison Horst` clearly depicts our vision of having special columns that hold geometry, tagged along with their properties in a `DataFrame`. 
~~~<img src="https://user-images.githubusercontent.com/520851/50280460-e35c1880-044c-11e9-9ed7-cc46754e49db.jpg" alt="customizable"/>~~~

So we started working towards a ~~~<ins>GeoDataFrames.jl</ins>~~~ package, that would wrap an `Array{Feature}` into a `GeoTable`.

```julia
struct GeoTable{T<:Array}
    features::T
end
```
and a `GeoTableRow` would handle the individual features
```julia
struct GeoTableRow{T, Names, Types}
    geometry::T
    properties::NamedTuple{Names, Types}
end
```
## May and further
Currently many packages define their own geometry types, and rely on the ~~~<a href="https://github.com/JuliaGeo/GeoInterface.jl">GeoInterface</a>~~~ to exchange between different representations. 
~~~<a href="https://github.com/JuliaGeometry/GeometryBasics">GeometryBasics</a>~~~ is an amazing API designed by
~~~<a href="https://github.com/SimonDanisch">Simon Danisch</a>~~~ from the beginning to work well for geospatial applications. It has well defined standard geometry types along with a good metadata support that allows to represent both geometries and properties as features rows in a `DataFrame` through ~~~<a href="https://github.com/JuliaArrays/StructArrays.jl">StructArrays</a>~~~ that supports the Tables interface .

With the above points in mind, we decided to go against the Python/R convention, i.e. having a separate `GeoDataFrames` package since the same functionality can now be availed in individual packages via `GeometryBasics`.
We modified our plans to work with the `GeometryBasics` API and migrate `Shapefile.jl` from using its own geometry types to GeometryBasics types and do the same for ~~~<a href="https://github.com/visr/GeoJSONTables">GeoJSONTables</a>~~~.
