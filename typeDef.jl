module webmap

export sitePage

#used to return information in exploreSite
type sitePage
    url::String
    depth::Int64
    success::Bool
end

end
