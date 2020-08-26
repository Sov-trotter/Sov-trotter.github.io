@def title = "Workflow"

# GeometryBasics support
## [WIP] ~~~<a href="https://github.com/JuliaGeo/Shapefile.jl/pull/39">Shapefile.jl</a>~~~:
* `GeoInterface` geometry types are replaced by the meta-geometry types from `GeometryBasics`
```julia
const Point = Point{2, Float64}

const MultiPoint = typeof(MultiPointMeta(y::Float64[Point(0)], m::Float64, 
                                         boundingbox=Rect(0.0, 0.0, 2.0, 2.0))) 

# and so on for other shapefile geometries
```

* Geometry contructors:
The construction of geometries is pretty simple and is handled well by `GeometryBasics` meta-geometry constructors, except for `Polygon` where we had to take an extra dependency to capture the case where it might have ~~~<a href="https://gist.github.com/jkrumbiegel/b82def0a3fb0a822963ec7f97278190c">multiple exterior rings</a>~~~. ~~~<br>~~~Thanks to ~~~<a href="https://github.com/greimel">Fabian Greimel</a>~~~, who ~~~<a href="https://github.com/JuliaGeo/Shapefile.jl/pull/39#issuecomment-671595669">solved</a>~~~ it in no time!

* Tabular Interface
We put the collection of meta-geometries and the properties file `.dbf` into a `StructArray` for tablular representation.   
```julia
function structarray(shp::Handle, dbf::DBFTables.Table)
    dbf_cols = Tables.columntable(dbf)
    meta = collect(GB.meta(s) for s in shp.shapes)
    meta_cols = Tables.columntable(meta)
    return StructArray(Geometry = collect(GB.metafree(i) for i in shp.shapes); meta_cols..., dbf_cols...)
end
```
## [WIP]~~~<a href="https://github.com/visr/GeoJSONTables.jl/pull/3">GeoJSONTables.jl</a>~~~:
* Feature
The package defines it's own Feature type that binds a geometry with it's properties. We went for this method rather than directly using GeometryBasics metageometry constructors to be able to support the case of heterogeneous geomtries that has been discussed below.
```julia
struct Feature{T, Names, Types}
    geometry::T
    properties::NamedTuple{Names, Types}
end
```

* Methods
Unlike `Shapefile.jl`, `GeoJSONTables.jl` follows a semi-lazy `JSON` parsing. A `read()` method directly reads the raw jsonbytes into a StructArray `Table`.
The `read()` method has two major parts:
        
        1) The `JSON3` parsing:
```julia
    fc = JSON3.read(jsonbytes)
``` 
        2) Populating and constructing GeometryBasics features :

```julia
    f = fc.features
     for f in jsonfeatures 
            geom = f.geometry
            prop = f.properties
            
            # only properties missing
            if geom !== nothing && prop === nothing
                Feature(geometry(geom), miss(a))
            
            # only geometry missing            
            elseif geom === nothing && prop !== nothing
                Feature(missing, prop)
            
            # none missing
            elseif geom !== nothing && prop !== nothing
                Feature(geometry(geom), prop)
            
            # both missing            
            elseif geom === nothing && prop === nothing
                Feature(missing, miss(a))
            end
        end
``` 

* Missing values
The package now supports efficient handling of `missing` data. This happens right during the construction of geometries(`GeoJSONTables.geometry` method that accepts a `JSON3.Object`). 
In the above example you can see a `miss()` method, which captures all the cases where a `JSON3` output might reult in `nothing`.

* StructArrays and Tabular interface
This is the part that needed a careful design. One of the features of a `GeoJSON` format is that it allows for heterogeneous features i.e, there can be multiple geometry types in a single `GeoJSON` file. The challenge was getting the Tables interface
to automatically widen to the appropriate types in case of heterogeneous features/geometries. eg: If a Feature has a `Point` type and a `Polygon` type, the type of our geometries column should automatically widen to `Any` and the Feature as `Feature{Any, Names, Types}`.
This required defining `StructArrays.staticschema`, `StructArrays.createinstance` and `Base.getproperty` overloads to work well with our `Feature` type.
The method is well documented in ~~~<a href="https://github.com/JuliaArrays/StructArrays.jl#advanced-structures-with-non-standard-data-layout">StructArrays.jl</a>~~~.

* Lower level interface
For a faster, lower level interface and greater flexibility with the data, one can directly have a `JSON3.Dict` to avoid the process of  conversion to GeometryBasics geometries and the Tables interface. Though it is not recommended if one wishes to use the data further for processing, plotting or performing spatial operations.
```julia
GeoJSONTables.JSON3.read(jsonbytes)
```