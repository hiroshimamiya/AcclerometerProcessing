### features
We are not supposed to give participant_ID as part of features. No. of samples was also removed because the value was same for all records. Currently, we are using 67 features for training our model. Note that the walmsley model ultimately uses only 37-38 features. (Seen from accelerometer library prediction code after loading the model file)

### process_acc.py
We used this for training the classification model. We used the methods which the accelerometer library was calling and directly added them to the jupyter notebook for training and loading models separately.

trainClassificationModel was fixed as described in the [process_acc_fix.md](process_acc_fix.md).

###### More info:
- We take the following features in temporal domain x,y,x and convert to spectral domain using FFT to obtain a set of 87 features.

- Frequency domain: https://pysdr.org/content/frequency_domain.html
Understanding what is frequency domain, conversion from time to frequency domain, properties in frequency domain without proofs and fast fourier transform.

- Different sources for feature extraction:
https://github.com/srvds/Human-Activity-Recognition?tab=readme-ov-file
https://github.com/jeandeducla/ML-Time-Series/tree/master
https://tsfel.readthedocs.io/en/latest/descriptions/get_started.html

This work is based on: https://arxiv.org/html/2402.19229v1

Faeture engineering techniques: https://www.youtube.com/watch?v=GduT2ZCc26E

what-is-the-best-way-to-remember-the-difference-between-sensitivity-specificity: [link](https://stats.stackexchange.com/questions/122225/what-is-the-best-way-to-remember-the-difference-between-sensitivity-specificity)

https://www.analyticsvidhya.com/blog/2022/07/step-by-step-exploratory-data-analysis-eda-using-python/
https://www.analyticsvidhya.com/blog/2021/09/complete-guide-to-feature-engineering-zero-to-hero/

https://nipunbatra.github.io/hmm/

https://mcgill-my.sharepoint.com/personal/hiroshi_mamiya_mcgill_ca/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fhiroshi%5Fmamiya%5Fmcgill%5Fca%2FDocuments%2FMicrosoft%20Teams%20Chat%20Files%2Fbjsports%2D2022%2DSeptember%2D56%2D18%2D1008%2Dinline%2Dsupplementary%2Dmaterial%2D1%20%283%29%2Epdf&parent=%2Fpersonal%2Fhiroshi%5Fmamiya%5Fmcgill%5Fca%2FDocuments%2FMicrosoft%20Teams%20Chat%20Files&ga=1

https://medium.com/@rehanmbl/extracting-time-domain-and-frequency-domain-features-from-a-signal-python-implementation-1-2-d36148c949ba

https://harvard-edge.github.io/cs249r_book/contents/dsp_spectral_features_block/dsp_spectral_features_block.html

https://scikit-learn.org/stable/modules/cross_validation.html#leave-one-group-out
https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.LeaveOneOut.html

https://bjsm.bmj.com/content/56/18/1008#DC1
https://learncsdesigns.medium.com/understanding-data-engineering-236cf6c16563