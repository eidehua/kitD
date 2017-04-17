package com.nacosiren;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.select.Elements;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;

/**
 * Created by naco_siren on 4/9/17.
 */
public class CatCrawler {
    /* Params: */
    private static final int TIMEOUT_LIMIT = 8000;
    private static final int GET_HTML_RETRY_TIMES = 3;
    private static final int DOWNLOAD_RETRY_TIMES = 3;

    /* Input */
    private CatGender _catGender;

    private String _url;
    private int _pageCount;

    private String _outDirName;

    /* Data: */
    private int _startCatIndex;


    public CatCrawler(CatGender catGender){
        //this._pageCount = pageCount;
        this._catGender = catGender;
        switch (_catGender) {
            case MALE:
                this._url = "http://bestfriends.org/adopt/adopt-our-sanctuary/cats?animalBreed=All&animalGeneralAge=All&animalGeneralSizePotential=All&animalColor=All&animalSex=1&animalName=&page=";
                _pageCount = 18;

                this._outDirName = "output-female";
                break;

            case FEMALE:
                this._url = "http://bestfriends.org/adopt/adopt-our-sanctuary/cats?animalBreed=All&animalGeneralAge=All&animalGeneralSizePotential=All&animalColor=All&animalSex=2&animalName=&page=";
                _pageCount = 18;

                this._outDirName = "output-female";
                break;

            default:
                break;
        }

    }


    public void startCrawling(){
        //Paths.get(".").toAbsolutePath().normalize().toString();
        File directory = new File(_outDirName);
        if (directory.exists() == false || directory.isFile()) {
            if(directory.mkdir() == false) {
                System.err.println("> Failed to make directory! Crawling terminated!");
                return;
            }
        }


        this._startCatIndex = 0;

        for (int pageIndex = 1; pageIndex <= _pageCount; pageIndex++) {
            crawlPage(pageIndex, _startCatIndex);
        }



    }

    public void crawlPage(int pageIndex, int startCatIndex) {
        /* Parse HTML */
        Document document = null;

        boolean hasGotHTML = false;
        int getHTMLRetryTimes = 0;
        while (hasGotHTML == false && getHTMLRetryTimes < GET_HTML_RETRY_TIMES) {
            //isSuccess = true;
            System.out.println("> Getting page #" + pageIndex + ", trial #" + getHTMLRetryTimes);

            try {

                /* Fetch and parse the web page's HTML document */
                document = Jsoup.connect(_url + pageIndex)
                        .timeout(TIMEOUT_LIMIT)
                        .get();

                hasGotHTML = true;

            } catch (IOException e) {
                e.printStackTrace();
                System.err.println(e.getMessage());

                getHTMLRetryTimes++;
                hasGotHTML = false;
            }
        }
        if (getHTMLRetryTimes >= GET_HTML_RETRY_TIMES) {
            System.out.println("> Failed to get page #" + pageIndex + ", continue next page!");
            return;
        }



        /* Locate the cats */
        Element eleBlockSystemMain = document.body().getElementById("block-system-main");
        Element root = eleBlockSystemMain.getElementsByClass("view-content").first();

        ArrayList<Element> divCatItems = new ArrayList<>();
        for (Element catItem : root.children()) {
            if (catItem.className().equals("views-row animal-item-view")) {
                divCatItems.add(catItem);
            }
        }
        int catsCount = divCatItems.size();
        System.out.println("> " + catsCount + " cats are found!");


        /* Process cat items one by one */
        for (int i = 0; i < catsCount; i++) {
                    /* Extract cat info */
            Element catItem = divCatItems.get(i);

            // Image
            String imageHref = null;
            {
                Element div = catItem.child(0);
                Element a = div.child(0);
                Element img = a.child(0);
                imageHref = img.attr("src");
            }

            // Name
            String name = null;
            String specHref = null;
            {
                Element div = catItem.child(1);
                Element a = div.child(0);
                name = a.text().trim();
                specHref = a.attr("href");
            }

            // Description
            String description = null;
            {
                Element h2 = catItem.child(2);
                description = h2.text().trim();
            }

            // Cat info instace
            CatInfo catInfo = new CatInfo(startCatIndex, name, _catGender, imageHref);
            catInfo._description = description;
            catInfo._specHref = specHref;



            /* Save cat info in a text file */
            String infoOutputFileName = _outDirName + File.separator + catInfo._index + ".txt";
            try {
                PrintWriter writer = new PrintWriter(new File(infoOutputFileName));

                writer.println(catInfo._index);
                writer.println(catInfo._name);
                writer.println(catInfo._description);
                writer.println(catInfo._specHref);

                writer.flush();
                writer.close();

            } catch (IOException e) {
                e.printStackTrace();
                System.err.println(e.getMessage());
            }


            /* Download the cat image */
            String imageOutputFileName = _outDirName + File.separator + catInfo._index + ".jpg";

            boolean hasDownloadedImage = false;
            int downloadRetryTimes = 0;
            while (hasDownloadedImage == false && downloadRetryTimes < DOWNLOAD_RETRY_TIMES) {
                try {
                    BufferedImage bufferedImage = ImageIO.read(new URL(imageHref));
                    File file = new File(imageOutputFileName);
                    ImageIO.write(bufferedImage, "jpg", file);

                    hasDownloadedImage = true;
                } catch (IOException e) {
                    e.printStackTrace();
                    System.err.println(e.getMessage());

                    downloadRetryTimes++;
                    hasDownloadedImage = false;
                }
            }
            if (downloadRetryTimes >= DOWNLOAD_RETRY_TIMES) {
                System.out.println("> Failed to download #" + startCatIndex + ", continue next cat!");
                continue;
            }

            startCatIndex++;
        }

        /* Update next page's start index */
        _startCatIndex = startCatIndex;

    }

    class CatInfo {
        // Essential
        int _index;
        String _name;
        CatGender _catGender;
        String _imageHref;

        // Useful
        String _breed;
        String _color;

        // Others
        String _specHref;
        String _description;


        public CatInfo(int index, String name, CatGender catGender, String imageHref){
            this._index = index;
            this._name = name;
            this._catGender = catGender;
            this._imageHref = imageHref;
        }

        @Override
        public String toString() {
            return "#" + _index + " [" + _name + "] [" + _description + "]";
        }
    }
}
