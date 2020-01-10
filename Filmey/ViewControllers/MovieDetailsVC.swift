//
//  MovieDetails.swift
//  Filmey
//
//  Created by Asmaa Tarek on 1/6/2019.
//  Copyright © 2020 Asmaa Tarek. All rights reserved.
//

import UIKit
import Cosmos
import SafariServices

class MovieDetailsVC: UIViewController {
    
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var overviewTxt: UITextView!
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var trailersTable: UITableView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var starsCosmos: CosmosView!
    
    var isFavourite = false
    var selectedMovieID = 0
    var trailersArr = [TrailerData]()
    var selectedMovie: MovieModel!
    var coreMovie = [FavoriteMovies]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.trailersTable.isHidden = true
        getTrailers()
        trailersTable.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        GetMovieDetails.getMovieById(movieID: selectedMovieID) { (responseModel, error) in
            if responseModel != nil && error == nil
            {
                self.selectedMovie = responseModel
                self.updateUI()
            }
        }
        let _ = checkIsFavourite()
    }
    
    func updateUI()
    {
        
        
        movieTitleLabel.text = selectedMovie.original_title
        releaseDateLabel.text = selectedMovie.release_date
        rateLabel.text = "\(selectedMovie.vote_average) / 10"
        overviewTxt.text = selectedMovie.overview
        movieImg.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w185/\(selectedMovie.poster_path)"), placeholderImage: UIImage(named: "popcorn"),completed: nil)
        starsCosmos.settings.fillMode = .precise
        starsCosmos.rating = selectedMovie.vote_average / 2
    }
    
    func getTrailers()
    {
        TrailerServices.getTrailers(movieID: selectedMovieID) { (responseModel, error) in
            if responseModel != nil && error == nil
            {
                for i in 0..<responseModel!.count
                {
                    if responseModel![i].site == "YouTube" && responseModel![i].type == "Trailer"
                    {
                        self.trailersArr.append(responseModel![i])
                    }
                }
                DispatchQueue.main.async
                {
                    if self.trailersArr.isEmpty
                 {
                   self.trailersTable.isHidden = true
                 }
                 else
                 {
                   self.trailersTable.isHidden = false
                  }
                  self.trailersTable.reloadData()
                }
            }
        }
    }
    
    func checkIsFavourite() -> [FavoriteMovies]
    {
        let arr = CoreDataHandler.checkforSpecificItemFromCoreData(movieID: Int64(selectedMovieID))
        if arr.isEmpty
        {
            favouriteBtn.setTitle("+  Add to favourites", for: .normal)
            isFavourite =  false
        }
        else
        {
            favouriteBtn.setTitle("x Remove from favourites", for: .normal)
            isFavourite = true
            
        }
        return arr
    }
    
    @IBAction func addToFavBtnPressed(_ sender: UIButton)
    {
         coreMovie = checkIsFavourite()
        if isFavourite
        {
            showAlertView(message: "Are you sure want to delete movie from favourites")
            
        }
        else
        {
            let favMovie = FavoriteMovies(context: CoreDataHandler.getCoreDataobject())
            favMovie.id = Int64(selectedMovie.id)
            favMovie.original_title = selectedMovie.original_title
            favMovie.overview = selectedMovie.overview
            favMovie.release_date = selectedMovie.release_date
            favMovie.vote_average = selectedMovie.vote_average
            favMovie.poster_path = selectedMovie.poster_path
            CoreDataHandler.saveIntoCoreData(movieItem: favMovie)
            favouriteBtn.setTitle("x Remove from favourites", for: .normal)
        }
    }
    func showAlertView(message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            let _ = CoreDataHandler.deleteObjectFromCoreData(movieItem: self.coreMovie[0]) ?? []
            self.favouriteBtn.setTitle("+  Add to favourites", for: .normal)

        }
        let action2 = UIAlertAction(title: "Cancel", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
       alert.addAction(action1)
        alert.addAction(action2)

       self.present(alert, animated: true, completion: nil)
    }
}

extension MovieDetailsVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return trailersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = trailersArr[indexPath.row].name
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(named: "youtube")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Trailers"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let url = URL(string: "https://www.youtube.com/watch?v=\(trailersArr[indexPath.row].key)") else {return}
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    
}
