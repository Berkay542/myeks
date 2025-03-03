module "network" {
    source                     = "./modules/network"
    
    env                        = var.env
    zone1                      = var.zone1
    zone2                      = var.zone2
    eks_name                   = var.eks_name
    region                     = var.region
    cidr_block                 = var.cidr_block
    private_subnet_cidrs       = var.private_subnet_cidrs
    public_subnet_cidrs        = var.public_subnet_cidrs
    availability_zones         = var.availability_zones
    private_subnet_ids         = var.private_subnet_ids
}



module "compute" {
    source = "./modules/compute"
    
    env                        = var.env
    project                    = var.project
    eks_name                   = var.eks_name
    vpc_id =                   = module.network.aws_vpc_id
    private_subnet_ids         = var.private_subnet_ids
    public_subnet_ids          = var.public_subnet_ids
    k8s-version                = var.k8s-version
    nodegroups-name            = var.nodegroups-name
    bastion_cidr               = var.bastion_cidr


}
 

module "user" {
    source = "./modules/user"

    eks_name = module.compute.eks_cluster
  
}