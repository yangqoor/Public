# https://predictivehacks.com/topic-modelling-with-nmf-in-python/
import pandas as pd
from sklearn.decomposition import NMF
from sklearn.feature_extraction.text import TfidfVectorizer
 
documents = pd.read_csv('../../../_data/news-data.csv', error_bad_lines=False)
documents.head()

# use tfidf by removing tokens that don't appear in at least 50 documents
vect = TfidfVectorizer(min_df=50, stop_words='english')
 
# Fit and transform
X = vect.fit_transform(documents.headline_text)

# Create an NMF instance: model
# the 10 components will be the topics
model = NMF(n_components=10, random_state=5)
 
# Fit the model to TF-IDF
model.fit(X)
 
# Transform the TF-IDF: nmf_features
nmf_features = model.transform(X)

# Create a DataFrame: components_df
components_df = pd.DataFrame(model.components_, columns=vect.get_feature_names())
print(components_df)

for topic in range(components_df.shape[0]):
    tmp = components_df.iloc[topic]
    print(f'For topic {topic+1} the words with the highest value are:')
    print(tmp.nlargest(10))
    print('\n')

my_document = documents.headline_text[55]
print(my_document)

pd.DataFrame(nmf_features).loc[55]
pd.DataFrame(nmf_features).loc[55].idxmax()
pd.DataFrame(nmf_features).idxmax()

my_news = """15-year-old girl stabbed to death in grocery store during fight with 4 younger girls
Authorities said they gathered lots of evidence from videos on social media"""
 
# Transform the TF-IDF
X = vect.transform([my_news])
# Transform the TF-IDF: nmf_features
nmf_features = model.transform(X)
 
print(pd.DataFrame(nmf_features))
print(pd.DataFrame(nmf_features).idxmax(axis=1))


