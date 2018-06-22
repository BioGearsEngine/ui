#include "ScenarioData.h"



ScenarioData::ScenarioData(std::string &filePath) : file_name_(filePath)
{
}


ScenarioData::~ScenarioData()
{
}

std::vector<std::string>& ScenarioData::getHeaders()
{
	if(headers_vector_.empty())
	{
		setHeaders();
	}
	return headers_vector_;
}

void ScenarioData::setHeaders()
{
	std::string line;
	std::ifstream dataReader(file_name_);
	if(!dataReader.is_open())
	{
		std::cout << "Error: Could not open file" << std::endl;
	}
	else
	{
		std::getline(dataReader, line);
		dataReader.close();
		boost::split(headers_vector_, line, boost::is_any_of(","),boost::token_compress_off);
		headers_vector_.erase(headers_vector_.begin());	//Remove time from list
		headers_vector_.emplace(headers_vector_.begin(), "Select a property to plot");
	}
}

void ScenarioData::SetDataSeries(std::string &y_header)
{
	std::string line;
	std::ifstream dataReader(file_name_);
	bool x_def = false;
	if (!x_data_.empty())
		x_def = true;

	if(!dataReader.is_open())
	{
		std::cout << "Error: Could not open file" << std::endl;
	}
	else
	{
		auto y_itr = std::find(headers_vector_.begin(),headers_vector_.end(),y_header);	//iterator to column containing desired data
		if(y_itr!=headers_vector_.end())
		{
			int y_index = y_itr - headers_vector_.begin();
			std::vector<std::string> dataLine;
			std::getline(dataReader, line);	//Discard first line, since this has the headers
			while (std::getline(dataReader, line))
			{
				boost::split(dataLine, line, boost::is_any_of(","), boost::token_compress_off);
				if (dataLine.size() < 2)
					break;
				if (!x_def)
				{
					x_data_.push_back(std::stod(dataLine[0]));
				}
				y_data_.push_back(std::stod(dataLine[y_index]));
			}
		}
		else
		{
			std::cout << "Error: Could not find data header in file" << std::endl;
		}
	}
}

std::vector<double>& ScenarioData::getXSeries()
{
	return x_data_;
}

std::vector<double>& ScenarioData::getYSeries()
{
	return y_data_;
}
