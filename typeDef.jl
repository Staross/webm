module webmap

export sitePage

#used to return information in exploreSite
type sitePage
    url::String
    parentUrl::String
    depth::Integer
    success::Bool
end

end
